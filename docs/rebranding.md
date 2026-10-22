# Rebranding: Buzz → Corevia Talk

Corevia Talk is a fork of [Buzz](https://github.com/block/buzz) by Block, Inc.
(Apache-2.0). The unbranded history lives on `my-changes`; the branded tree is
**generated** from it by `scripts/rebrand.py`, so upstream merges stay cheap.

## Workflow

```bash
git checkout my-changes
git fetch upstream && git merge upstream/main     # resolve conflicts here
git checkout -B corevia-branding my-changes
python3 scripts/rebrand.py                        # idempotent; --dry-run to preview
git add -A && git commit -s -m "chore: rebrand Buzz to Corevia Talk"
```

Never hand-edit branded names on `my-changes`; extend the script instead.

## Naming map

| Form | Value | Used for |
|------|-------|----------|
| kebab | `corevia-talk` | crates, packages, directories, CLI, URL scheme, Helm |
| snake | `corevia_talk` | Rust/Dart identifiers, Postgres user/db/password |
| Pascal / camel | `CoreviaTalk` / `coreviaTalk` | types, Swift modules, Tauri `productName` |
| UPPER | `COREVIA_TALK` | environment variables, constants |
| flat | `coreviatalk` | reverse-DNS bundle / application ids |
| display | `Corevia Talk` | user-visible text, docs prose, Persian strings |

`productName` is `CoreviaTalk` (no space) because Tauri derives `.app`/`.dmg`
names from it and the release scripts use them unquoted. The user-facing name in
`Info.plist` stays `Corevia Talk`.

## Deliberately left unchanged

* `LICENSE`, `NOTICE`, `CHANGELOG.md` (history), this document and the script.
* Links and references to the upstream project: `block/buzz…`, `squareup/…`.
* Services operated by Block: every `*.buzz.xyz` host (push gateway, pairing,
  design, sample communities), `buzzdotxyz`, the Railway template id.
* The English word “buzzard”.
* Logos and icons (the open logo is kept for now).

## Things you must decide before shipping

* **Bundle ids** became `xyz.block.coreviatalk.*`. The `xyz.block` prefix belongs
  to Block; pick your own reverse-DNS prefix before publishing or signing builds.
* **Auto-update** `endpoints` in `desktop/src-tauri/tauri.conf.json` is empty and
  `github.repository == 'block/buzz'` release conditions are kept on purpose, so
  forks do not publish or consume Block's releases. Configure your own.
* **Push gateway / pairing / design hosts** still point at Block's `buzz.xyz`
  services. Run your own or replace them.
* **Wire format.** Tag names, kinds' string identifiers, `buzz://` deep links and
  data-dir names (`~/.buzz` → `~/.corevia-talk`) are renamed everywhere in this
  repo, so Corevia Talk clients and relays interoperate with each other but not
  with unmodified Buzz relays or existing local data. Move data dirs by hand.
* **Database** names/users are now `corevia_talk`; existing dev databases must be
  recreated (`just reset`).
* Full Cargo/pnpm/Flutter builds were not run when this was authored (no
  registry access); run `just ci` once before relying on the branded tree.
