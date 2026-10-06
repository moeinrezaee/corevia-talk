import { tl } from "@/shared/i18n/tl";
/**
 * Always-visible cue shown in Agent Defaults when a global `OPENAI_API_KEY`
 * row exists (nonblank).  The Advanced section is collapsed by default, so
 * the `keyAnnotations` hint on that row is invisible until the user opens it
 * — this cue bridges the gap by surfacing the information at the decision
 * point.
 *
 * Renders nothing when `OPENAI_API_KEY` is absent or blank.
 */
export function CardMintKeyCue({
  envVars,
}: {
  envVars: Record<string, string>;
}) {
  const isSet =
    "OPENAI_API_KEY" in envVars &&
    (envVars.OPENAI_API_KEY ?? "").trim().length > 0;
  if (!isSet) return null;

  return (
    <p
      className="text-xs text-muted-foreground"
      data-testid="card-mint-key-cue"
    >
      {tl("Card-minting key")}{" "}
      <span className="font-mono">{tl("OPENAI_API_KEY")}</span>{" "}
      {tl("is set under Advanced → Environment variables.")}
    </p>
  );
}
