import "@/shared/i18n/installPersianDates";
import React from "react";
import ReactDOM from "react-dom/client";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { App } from "@/app/App";
import "@fontsource-variable/inter/wght.css";
import "@/shared/styles/globals.css";
import { installAutoDirection } from "@/shared/i18n/autoDirection";
import { installContentAlignment } from "@/shared/i18n/contentAlignment";
import { installDomTranslator } from "@/shared/i18n/domTranslator";
import {
  getLanguage,
  initializeLanguagePreference,
  isRtlLanguage,
} from "@/shared/i18n/languagePreference";
import { ThemeProvider } from "@/shared/theme/ThemeProvider";
import { Toaster } from "@/shared/ui/sonner";
import { TooltipProvider } from "@/shared/ui/tooltip";

// Apply lang/dir to <html> before React renders so the layout never flips.
initializeLanguagePreference();

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
      networkMode: "always",
      gcTime: 5 * 60 * 1_000,
    },
    mutations: {
      networkMode: "always",
    },
  },
});

ReactDOM.createRoot(document.getElementById("root") as HTMLElement).render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      <ThemeProvider>
        <TooltipProvider delayDuration={300}>
          <App />
          <Toaster />
        </TooltipProvider>
      </ThemeProvider>
    </QueryClientProvider>
  </React.StrictMode>,
);

const language = getLanguage();
if (language === "fa") installDomTranslator();
installAutoDirection();
installContentAlignment(isRtlLanguage(language));
