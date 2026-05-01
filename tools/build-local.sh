#!/bin/bash
set -e

# ──────────────────────────────────────────────
# Lokaler ZMK Build mit Docker
# ──────────────────────────────────────────────
# Baut beide Hälften der Corne und legt die .uf2
# Dateien in ./firmware/ ab.
# ──────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ZMK_DIR="$CONFIG_DIR/.zmk"

mkdir -p "$CONFIG_DIR/firmware"
mkdir -p "$ZMK_DIR"

echo "=== ZMK Firmware Build ==="
echo "Config:  $CONFIG_DIR"
echo "ZMK src: $ZMK_DIR"
echo ""

# ── 1. ZMK Source holen (einmalig) ──
if [ ! -f "$ZMK_DIR/app/CMakeLists.txt" ]; then
    echo "📥 ZMK Firmware wird geklont..."
    git clone --depth 1 https://github.com/zmkfirmware/zmk.git "$ZMK_DIR"
    cd "$ZMK_DIR"

    docker run --rm --platform linux/amd64 --entrypoint sh \
        -v "$ZMK_DIR:/zmk" -w /zmk \
        zmkfirmware/zephyr-west-action-arm \
        -c "west init -l app/ && west update"
else
    echo "✅ ZMK Source vorhanden"
fi

# ── 2. Beide Seiten bauen ──
for SIDE in left right; do
    echo ""
    echo "🔨 Baue $SIDE ..."

    rm -rf "$ZMK_DIR/app/build/$SIDE"

    docker run --rm --platform linux/amd64 --entrypoint west \
        -v "$ZMK_DIR:/zmk" \
        -v "$CONFIG_DIR/config:/config" \
        -w /zmk/app \
        zmkfirmware/zephyr-west-action-arm \
        build -b nice_nano_v2 \
            -d "build/$SIDE" \
            -- -DSHIELD="splitkb_aurora_corne_${SIDE}" \
               -DZMK_CONFIG="/config"

    # Firmware kopieren
    cp "$ZMK_DIR/app/build/$SIDE/zephyr/zmk.uf2" \
       "$CONFIG_DIR/firmware/splitkb_aurora_corne_${SIDE}.uf2"

    echo "✅ $SIDE -> firmware/splitkb_aurora_corne_${SIDE}.uf2"
done

echo ""
echo "=== Fertig! ==="
echo "Firmware liegt in: $CONFIG_DIR/firmware/"
ls -la "$CONFIG_DIR/firmware/"*.uf2 2>/dev/null
