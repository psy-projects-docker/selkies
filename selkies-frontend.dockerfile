FROM alpine:latest

RUN <<'EOF'
set -eux

printf "%s\n" "Install Build Deps" \
  "██████████████████████████████████████████████████" \
  "▒▒                                              ▒▒" \
  "▒▒             Install Build Deps               ▒▒" \
  "▒▒                                              ▒▒" \
  "██████████████████████████████████████████████████"
apk add --no-cache \
  "cmake" \
  "git" \
  "nodejs" \
  "npm"

printf "%s\n" "Ingest Code" \
  "██████████████████████████████████████████████████" \
  "▒▒                                              ▒▒" \
  "▒▒                  Ingest Code                 ▒▒" \
  "▒▒                                              ▒▒" \
  "██████████████████████████████████████████████████"
git clone "https://github.com/selkies-project/selkies.git" "/src"
cd "/src"
git checkout -f "a47ade9aad57758f0e3ee421240db53ad8c3d3b2"

printf "%s\n" "Build Shared Core Library" \
  "██████████████████████████████████████████████████" \
  "▒▒                                              ▒▒" \
  "▒▒          Build Shared Core Library           ▒▒" \
  "▒▒                                              ▒▒" \
  "██████████████████████████████████████████████████"
cd "/src/addons/gst-web-core"
npm install
npm run build

printf "%s\n" "Build Multiple Dashboards" \
  "██████████████████████████████████████████████████" \
  "▒▒                                              ▒▒" \
  "▒▒          Build Multiple Dashboards           ▒▒" \
  "▒▒                                              ▒▒" \
  "██████████████████████████████████████████████████"
DASHBOARDS="selkies-dashboard selkies-dashboard-zinc selkies-dashboard-wish"
mkdir -p "/buildout"

for DASH in ${DASHBOARDS}; do
  printf "%s\n" "**** building ${DASH} ****"
  cd "/src/addons/${DASH}"

  cp ../"gst-web-core/dist/selkies-core.js" "src/"

  npm install
  npm run build

  mkdir -p "dist/src" "dist/nginx"

  cp ../"gst-web-core/dist/selkies-core.js" "dist/src/"
  cp ../"universal-touch-gamepad/universalTouchGamepad.js" "dist/src/"
  cp ../"gst-web-core/nginx"/* "dist/nginx/"
  cp -r ../"gst-web-core/dist/jsdb" "dist/"

  mkdir -p "/buildout/${DASH}"
  cp -a dist/. "/buildout/${DASH}/"
done
EOF
