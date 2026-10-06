import { Outlet, createRootRoute } from "@tanstack/react-router";
import { AppHeader } from "@/shared/ui/AppHeader";

export const Route = createRootRoute({
  component: RootLayout,
});

function RootLayout() {
  return (
    <div className="flex min-h-dvh flex-col">
      <AppHeader />
      <main className="flex flex-1 flex-col">
        <Outlet />
      </main>
    </div>
  );
}
