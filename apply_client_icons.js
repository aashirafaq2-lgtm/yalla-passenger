const sharp = require('sharp');
const path = require('path');
const fs = require('fs');

const passengerSrc = path.join(__dirname, '..', '..', 'client_assets', 'Yalla passanger logo.jpeg');
const driverSrc    = path.join(__dirname, '..', '..', 'client_assets', 'Yalla Driver logo.PNG');

const passengerIosDest = path.join(__dirname, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset');
const passengerAndroidRes = path.join(__dirname, 'android', 'app', 'src', 'main', 'res');

const driverIosDest = path.join(__dirname, '..', '..', 'Yalla Drive', 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset');
const driverAndroidRes = path.join(__dirname, '..', '..', 'Yalla Drive', 'android', 'app', 'src', 'main', 'res');

const iosSizes = [
    ['Icon-App-20x20@1x.png', 20],
    ['Icon-App-20x20@2x.png', 40],
    ['Icon-App-20x20@3x.png', 60],
    ['Icon-App-29x29@1x.png', 29],
    ['Icon-App-29x29@2x.png', 58],
    ['Icon-App-29x29@3x.png', 87],
    ['Icon-App-40x40@1x.png', 40],
    ['Icon-App-40x40@2x.png', 80],
    ['Icon-App-40x40@3x.png', 120],
    ['Icon-App-60x60@2x.png', 120],
    ['Icon-App-60x60@3x.png', 180],
    ['Icon-App-76x76@1x.png', 76],
    ['Icon-App-76x76@2x.png', 152],
    ['Icon-App-83.5x83.5@2x.png', 167],
    ['Icon-App-1024x1024@1x.png', 1024],
];

const androidSizes = [
    ['mipmap-mdpi', 48],
    ['mipmap-hdpi', 72],
    ['mipmap-xhdpi', 96],
    ['mipmap-xxhdpi', 144],
    ['mipmap-xxxhdpi', 192],
];

async function generateAppIcons(srcPath, iosDir, androidResDir, appName) {
    console.log(`\n========================================`);
    console.log(`Generating Icons for: ${appName}`);
    console.log(`Source: ${srcPath}`);
    console.log(`========================================`);

    if (!fs.existsSync(srcPath)) {
        throw new Error(`Source file not found: ${srcPath}`);
    }

    // 1. Generate iOS AppIcon.appiconset
    if (!fs.existsSync(iosDir)) fs.mkdirSync(iosDir, { recursive: true });
    for (const [filename, size] of iosSizes) {
        const outPath = path.join(iosDir, filename);
        await sharp(srcPath)
            .resize(size, size, { fit: 'cover' })
            .removeAlpha() // Critical for Apple App Store 1024x1024
            .png()
            .toFile(outPath);
        console.log(` [iOS] Generated ${filename} (${size}x${size})`);
    }

    // 2. Generate Android Mipmap Icons
    for (const [folder, size] of androidSizes) {
        const targetDir = path.join(androidResDir, folder);
        if (!fs.existsSync(targetDir)) fs.mkdirSync(targetDir, { recursive: true });

        // Generate ic_launcher.png
        await sharp(srcPath)
            .resize(size, size, { fit: 'cover' })
            .png()
            .toFile(path.join(targetDir, 'ic_launcher.png'));

        // Generate launcher_icon.png
        await sharp(srcPath)
            .resize(size, size, { fit: 'cover' })
            .png()
            .toFile(path.join(targetDir, 'launcher_icon.png'));

        console.log(` [Android] Generated ${folder} (${size}x${size})`);
    }
}

async function run() {
    // 1. Passenger App
    await generateAppIcons(passengerSrc, passengerIosDest, passengerAndroidRes, 'Yalla Passenger');

    // Update Passenger asset files
    const pIconDir = path.join(__dirname, 'assets', 'icon');
    if (!fs.existsSync(pIconDir)) fs.mkdirSync(pIconDir, { recursive: true });
    await sharp(passengerSrc).resize(1024, 1024).removeAlpha().png().toFile(path.join(pIconDir, 'app_icon.png'));
    await sharp(passengerSrc).resize(1024, 1024).removeAlpha().png().toFile(path.join(pIconDir, 'app_icon_no_alpha.png'));
    
    const pImgDir = path.join(__dirname, 'assets', 'images');
    if (!fs.existsSync(pImgDir)) fs.mkdirSync(pImgDir, { recursive: true });
    await sharp(passengerSrc).resize(1024, 1024).removeAlpha().png().toFile(path.join(pImgDir, 'app_logo.png'));
    console.log(` [Passenger] Updated Flutter assets/icon and assets/images`);

    // 2. Driver App
    await generateAppIcons(driverSrc, driverIosDest, driverAndroidRes, 'Yalla Driver');

    // Update Driver asset files
    const dImgDir = path.join(__dirname, '..', '..', 'Yalla Drive', 'assets', 'images');
    if (!fs.existsSync(dImgDir)) fs.mkdirSync(dImgDir, { recursive: true });
    await sharp(driverSrc).resize(1024, 1024).removeAlpha().png().toFile(path.join(dImgDir, 'app_logo.png'));

    const dIconDir = path.join(__dirname, '..', '..', 'Yalla Drive', 'assets', 'icon');
    if (!fs.existsSync(dIconDir)) fs.mkdirSync(dIconDir, { recursive: true });
    await sharp(driverSrc).resize(1024, 1024).removeAlpha().png().toFile(path.join(dIconDir, 'app_icon.png'));
    console.log(` [Driver] Updated Flutter assets/images and assets/icon`);

    console.log('\n SUCCESS: All icons for Passenger & Driver generated successfully!');
}

run().catch(e => {
    console.error('Error generating icons:', e);
    process.exit(1);
});
