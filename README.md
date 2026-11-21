# Twitch Emotes - dogesmile

Adds the emotes from the :dogesmile Discord server to [Twitch Emotes v2](https://www.curseforge.com/wow/addons/twitch-emotes-v2).
Type the emote name in chat (`doge`, `kekw`, ...). Typing `:` followed by a few letters opens the
autocomplete. You can also pick them from the Twitch Emotes menu (the "dogesmile" categories).

Where a name already exists in Twitch Emotes (`kekw`, `monkaS`, `COPIUM`, ...), the dogesmile version replaces it.

Download: [CurseForge](https://www.curseforge.com/wow/addons/twitch-emotes-dogesmile)

## Adding or changing emotes

1. Put the image (PNG, GIF or WEBP, static or animated) in `src/public/`. The file name is the
   emote name: `peepoclap.webp` becomes `peepoclap`. Names are case-sensitive. An optional `@<discord id>` suffix is ignored
   (`peepoclap@123456.webp`).
2. Run `python tools/build.py` (needs `pip install pillow`) and `/reload` in game to test.
3. Commit and push.

Images are scaled to 32x32. Animated images become frame strips (max 64 frames).

`src/private/` is git-ignored and never released. Images there are added to your local build only,
and replace a public image with the same Discord id.

## Releasing

Bump nothing by hand; the version comes from the git tag.

```sh
git tag v1.1
git push origin v1.1
```

GitHub Actions builds the textures, packages the addon and uploads it to CurseForge (with Twitch
Emotes v2 as a required dependency) and to GitHub Releases. The changelog is made from the commit
messages since the previous tag. Tags with `alpha`/`beta` in them (e.g. `v1.2-beta1`) upload as
alpha/beta files.

Every push to `main` also makes a test build you can download from the Actions run, without uploading.
