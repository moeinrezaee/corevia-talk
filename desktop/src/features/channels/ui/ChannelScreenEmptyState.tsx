import { tl } from "@/shared/i18n/tl";
export function ChannelScreenEmptyState() {
  return (
    <div className="flex min-h-0 flex-1 items-center justify-center px-6 py-8">
      <p className="text-sm text-muted-foreground">
        {tl("Select a channel to view messages.")}
      </p>
    </div>
  );
}
