import { defineConfig } from "drizzle-kit";

try {
  process.loadEnvFile();
} catch {}

// Every module owns its tables in src/modules/<name>/schema.ts (picked up by glob).
export default defineConfig({
  schema: ["./src/modules/*/schema.ts"],
  out: "./drizzle",
  dialect: "postgresql",
  dbCredentials: { url: process.env.DATABASE_URL! },
});
