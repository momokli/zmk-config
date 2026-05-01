#!/bin/bash
set -e

# ──────────────────────────────────────────────
# Lokaler ZMK Build (CI-kompatibel)
# ──────────────────────────────────────────────
# Nutzt das gleiche Docker-Image wie die GitHub
# Actions: zmkfirmware/zmk-build-arm:stable
# ──────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BASE_DIR="$CONFIG_DIR/.zmk-build"
IMG="zmkfirmware/zmk-build-arm:stable"

mkdir -p "$CONFIG_DIR/firmware"
mkdir -p "$BASE_DIR"

echo "=== ZMK Firmware Build ==="
echo "Config:  $CONFIG_DIR"
echo "Base:    $BASE_DIR"
echo "Image:   $IMG"
echo ""

# ── 1. Config ins Base-Verzeichnis kopieren ──
#    (wie CI: wenn module.yml existiert, wird in
#     tmp-Verzeichnis kopiert und von dort gebaut)
echo "📋 Kopiere Config..."
rm -rf "$BASE_DIR/config"
cp -R "$CONFIG_DIR/config" "$BASE_DIR/config"
cp -R "$CONFIG_DIR/zephyr" "$BASE_DIR/zephyr" 2>/dev/null || true

# ── 2. West Init + Update (einmalig) ──
if [ ! -f "$BASE_DIR/zmk/app/CMakeLists.txt" ]; then
    echo "📥 West Init + Update (ZMK + Zephyr holen)..."
    docker run --rm --platform linux/amd64 \
        -v "$BASE_DIR:/workspace" \
        -w /workspace \
        "$IMG" \
        sh -c "west init -l config/ && west update --fetch-opt=--filter=tree:0 && west zephyr-export"
else
    echo "✅ ZMK Source bereits vorhanden"
fi

# ── 3. Beide Seiten bauen ──
for SIDE in left right; do
    echo ""
    echo "🔨 Baue $SIDE ..."

    rm -rf "$BASE_DIR/build/$SIDE"

    docker run --rm --platform linux/amd64 \
        -v "$BASE_DIR:/workspace" \
        -w /workspace \
        "$IMG" \
        sh -c "west zephyr-export && west build -s zmk/app -d build/$SIDE \
            -b nice_nano \
            -- -DSHIELD='splitkb_aurora_corne_${SIDE}' \
               -DZMK_CONFIG='/workspace/config'"

    # Firmware kopieren
    cp "$BASE_DIR/build/$SIDE/zephyr/zmk.uf2" \
       "$CONFIG_DIR/firmware/splitkb_aurora_corne_${SIDE}.uf2"

    echo "✅ $SIDE -> firmware/splitkb_aurora_corne_${SIDE}.uf2"
done

echo ""
echo "=== Fertig! ==="
ls -la "$CONFIG_DIR/firmware/"*.uf2 2>/dev/null
