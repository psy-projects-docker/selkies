FROM lscr.io/linuxserver/xvfb:ubuntunoble AS xvfb
FROM alpine:latest

RUN <<-'EOF'
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
git checkout -f "348bc4f61da66198573e7e57db9a266aca1991d5"

printf "%s\n" "Build Shared Core Library" \
  "██████████████████████████████████████████████████" \
  "▒▒                                              ▒▒" \
  "▒▒          Build Shared Core Library           ▒▒" \
  "▒▒                                              ▒▒" \
  "██████████████████████████████████████████████████"
cd "/src/addons/selkies-web-core"
npm install
npm run build

printf "%s\n" "Build Multiple Dashboards" \
  "██████████████████████████████████████████████████" \
  "▒▒                                              ▒▒" \
  "▒▒          Build Multiple Dashboards           ▒▒" \
  "▒▒                                              ▒▒" \
  "██████████████████████████████████████████████████"
DASHBOARDS="selkies-dashboard selkies-dashboard-wish"
mkdir -p "/build-out"

for DASH in ${DASHBOARDS}; do
  printf "%s\n" "**** building ${DASH} ****"
  cd "/src/addons/${DASH}"

  cp ../"selkies-web-core/dist/selkies-core.js" "src/"

  npm install
  npm run build

  mkdir -p "dist/src" "dist/nginx"

  cp ../"selkies-web-core/dist/selkies-core.js" "dist/src/"
  cp ../"universal-touch-gamepad/universalTouchGamepad.js" "dist/src/"
  cp ../"selkies-web-core/nginx"/* "dist/nginx/"
  cp -r ../"selkies-web-core/dist/jsdb" "dist/"

  mkdir -p "/build-out/${DASH}"
  cp -a dist/. "/build-out/${DASH}/"
done
EOF

COPY --from=xvfb / /build-out/xvfb-fix