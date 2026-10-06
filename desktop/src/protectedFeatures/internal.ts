import type { FeatureDefinition } from "@/shared/features/types";
import { tl } from "@/shared/i18n/tl";

/** Definitions available only in the protected internal application build. */
export const protectedFeatureDefinitions: FeatureDefinition[] = [
  {
    id: "bestie",
    name: "Bestie",
    description: tl("Try a personal agent that is always close at hand"),
    platforms: ["desktop"],
  },
];
