import { spawn } from "node:child_process";
import { createRequire } from "node:module";
import { dirname, join } from "node:path";

const require = createRequire(new URL("../apps/mobile/package.json", import.meta.url));
const expoCli = join(dirname(require.resolve("expo/package.json")), "bin", "cli");
const child = spawn(
  process.execPath,
  [expoCli, "run:android", "--no-bundler", ...process.argv.slice(2)],
  {
    stdio: "inherit",
    env: { ...process.env, REACT_NATIVE_PACKAGER_HOSTNAME: "127.0.0.1" },
  },
);
child.on("error", (error) => {
  console.error(error.message);
  process.exitCode = 1;
});
child.on("exit", (code) => {
  process.exitCode = code ?? 1;
});
