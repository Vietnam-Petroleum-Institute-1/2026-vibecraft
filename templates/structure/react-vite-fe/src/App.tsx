import { Button } from './components/common/Button';
import { ModalContainer } from './components/common/Modal';
import { NotificationContainer } from './components/common/Notification';
import { useHealth } from './hooks/useHealth';

// Sample page demonstrating the required call chain: component → hook →
// service → api.client (never fetch() directly in a component — see
// AGENTS.md "Frontend specifics").
export function App() {
  const { health, error, check } = useHealth();

  return (
    <>
      <main className="flex min-h-screen flex-col items-center justify-center gap-4 p-24">
        <h1 className="text-2xl font-bold">[PROJECT_NAME]</h1>
        {error && <p className="text-red-600">Backend unreachable: {error}</p>}
        {health && <pre className="rounded bg-gray-100 p-4">{JSON.stringify(health, null, 2)}</pre>}
        <Button onClick={check}>Re-check backend health</Button>
      </main>
      {/* Renders modal.confirm()/notification.success()/... calls made
         anywhere in the app — see components/common/Modal and Notification. */}
      <ModalContainer />
      <NotificationContainer />
    </>
  );
}
