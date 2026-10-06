import { Star } from "lucide-react";

import type { ManagedAgent } from "@/shared/api/types";
import { tl, tlt } from "@/shared/i18n/tl";

export function BestieCardBadge({
  agent,
  isBestie,
}: {
  agent: ManagedAgent;
  isBestie: boolean;
}) {
  if (!isBestie) return null;

  return (
    <span
      aria-label={tlt("{0} is your Bestie", [agent.name])}
      className="inline-flex shrink-0 items-center justify-center text-foreground opacity-50"
      data-testid={`bestie-card-badge-${agent.pubkey}`}
      role="img"
      title={tl("Bestie")}
    >
      <Star className="h-4 w-4 fill-current" />
    </span>
  );
}
