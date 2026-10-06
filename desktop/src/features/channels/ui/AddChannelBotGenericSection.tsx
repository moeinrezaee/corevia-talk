import { Input } from "@/shared/ui/input";
import { Textarea } from "@/shared/ui/textarea";
import { tl } from "@/shared/i18n/tl";

type AddChannelBotGenericSectionProps = {
  disabled: boolean;
  name: string;
  prompt: string;
  onNameChange: (value: string) => void;
  onPromptChange: (value: string) => void;
};

export function AddChannelBotGenericSection({
  disabled,
  name,
  prompt,
  onNameChange,
  onPromptChange,
}: AddChannelBotGenericSectionProps) {
  return (
    <div className="space-y-5 rounded-2xl border border-border/70 bg-card/70 p-4">
      <div>
        <div className="text-sm font-medium">{tl("Generic agent")}</div>
        <p className="text-xs text-muted-foreground">
          {tl("Add one custom agent alongside any selected agents.")}
        </p>
      </div>

      <div className="space-y-1.5">
        <label className="text-sm font-medium" htmlFor="channel-generic-name">
          {tl("Name")}
        </label>
        <Input
          autoCapitalize="none"
          autoCorrect="off"
          disabled={disabled}
          id="channel-generic-name"
          onChange={(event) => onNameChange(event.target.value)}
          spellCheck={false}
          value={name}
        />
        <p className="text-xs text-muted-foreground">
          {tl("Defaults to the selected runtime name.")}
        </p>
      </div>

      <div className="space-y-1.5">
        <label className="text-sm font-medium" htmlFor="channel-generic-prompt">
          {tl("Prompt")}
        </label>
        <Textarea
          className="min-h-24"
          disabled={disabled}
          id="channel-generic-prompt"
          onChange={(event) => onPromptChange(event.target.value)}
          placeholder={tl("What should this agent help with in the channel?")}
          value={prompt}
        />
        <p className="text-xs text-muted-foreground">
          {tl("Saved as the generic agent's system prompt override.")}
        </p>
      </div>
    </div>
  );
}
