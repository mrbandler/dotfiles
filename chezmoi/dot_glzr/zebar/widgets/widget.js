import React, { useState, useEffect } from "https://esm.sh/react@18?dev";
import { createRoot } from "https://esm.sh/react-dom@18/client?dev";
import * as zebar from "https://esm.sh/zebar@2";

const providers = zebar.createProviderGroup({
  host: { type: "host" },
  glazewm: { type: "glazewm" },
  media: { type: "media" },
  cpu: { type: "cpu" },
  memory: { type: "memory" },
  network: { type: "network" },
  battery: { type: "battery" },
  keyboard: { type: "keyboard" },
  date: { type: "date", formatting: "T" },
});

createRoot(document.getElementById("root")).render(<Bar />);

/**
 * Checks whether the current monitor is the main monitor.
 * This is done by checking if the current monitor has a workspace named "main".
 *
 * @param {*} glazeOutput GlazeWM provider input.
 * @returns Flag, whether the current monitor is the main monitor.
 */
function isMainMonitor(glazeOutput) {
  if (!glazeOutput || !glazeOutput.currentMonitor) return false;

  return glazeOutput.currentMonitor.children.some(
    (c) => c.type === "workspace" && c.name === "main"
  );
}

/**
 * Left bar component.
 */
function Left() {
  const [output, setOutput] = useState(providers.outputMap);

  useEffect(() => {
    providers.onOutput(() => setOutput(providers.outputMap));
  }, []);

  return (
    <div className="left">
      {output.glazewm && (
        <div className="workspaces">
          {output.glazewm.currentWorkspaces.map((workspace) => (
            <button
              className={`workspace ${workspace.hasFocus && "focused"} ${
                workspace.isDisplayed && "displayed"
              }`}
              onClick={() =>
                output.glazewm.runCommand(`focus --workspace ${workspace.name}`)
              }
              key={workspace.name}
            >
              {workspace.displayName ?? workspace.name}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

/**
 * Center bar component.
 */
function Center() {
  const [output, setOutput] = useState(providers.outputMap);

  useEffect(() => {
    providers.onOutput(() => setOutput(providers.outputMap));
  }, []);

  return (
    <div className="center">
      {output.glazewm &&
        output.glazewm.bindingModes.map((bindingMode) => (
          <button className="binding-mode" key={bindingMode.name}>
            {bindingMode.displayName.toUpperCase() ??
              bindingMode.name.toUpperCase()}
          </button>
        ))}
    </div>
  );
}

/**
 * Right bar component.
 */
function Right() {
  const [output, setOutput] = useState(providers.outputMap);

  useEffect(() => {
    providers.onOutput(() => setOutput(providers.outputMap));
  }, []);

  // Get icon to show for current network status.
  function getNetworkIcon(networkOutput) {
    switch (networkOutput.defaultInterface?.type) {
      case "ethernet":
        return <i className="nf nf-md-ethernet_cable"></i>;
      case "wifi":
        if (networkOutput.defaultGateway?.signalStrength >= 80) {
          return <i className="nf nf-md-wifi_strength_4"></i>;
        } else if (networkOutput.defaultGateway?.signalStrength >= 65) {
          return <i className="nf nf-md-wifi_strength_3"></i>;
        } else if (networkOutput.defaultGateway?.signalStrength >= 40) {
          return <i className="nf nf-md-wifi_strength_2"></i>;
        } else if (networkOutput.defaultGateway?.signalStrength >= 25) {
          return <i className="nf nf-md-wifi_strength_1"></i>;
        } else {
          return <i className="nf nf-md-wifi_strength_outline"></i>;
        }
      default:
        return <i className="nf nf-md-wifi_strength_off_outline"></i>;
    }
  }

  // Get icon to show for how much of the battery is charged.
  function getBatteryIcon(batteryOutput) {
    if (batteryOutput.chargePercent > 90)
      return <i className="nf nf-fa-battery_4"></i>;
    if (batteryOutput.chargePercent > 70)
      return <i className="nf nf-fa-battery_3"></i>;
    if (batteryOutput.chargePercent > 40)
      return <i className="nf nf-fa-battery_2"></i>;
    if (batteryOutput.chargePercent > 20)
      return <i className="nf nf-fa-battery_1"></i>;
    return <i className="nf nf-fa-battery_0"></i>;
  }

  return (
    <div className="right">
      {isMainMonitor(output.glazewm) && output.keyboard && (
        <div className="keyboard">
          <i className="nf nf-md-keyboard"></i>
          {output.keyboard.layout
            .slice(output.keyboard.layout.indexOf("-") + 1)
            .replace(/\u0000/g, "")}
        </div>
      )}

      {isMainMonitor(output.glazewm) && output.battery && (
        <div className="battery">
          {/* Show icon for whether battery is charging. */}
          {output.battery.isCharging && (
            <i className="nf nf-md-power_plug charging-icon"></i>
          )}
          {getBatteryIcon(output.battery)}
          {Math.round(output.battery.chargePercent)}%
        </div>
      )}

      {isMainMonitor(output.glazewm) && output.network && (
        <div className="network">
          {getNetworkIcon(output.network)}
          {output.network.defaultGateway?.ssid}
        </div>
      )}

      {output.date && <div className="time">{output.date.formatted}</div>}
      {output.glazewm && (
        <button
          className={`tiling-direction nf ${
            output.glazewm.tilingDirection === "horizontal"
              ? "nf-md-swap_horizontal"
              : "nf-md-swap_vertical"
          }`}
          onClick={() => output.glazewm.runCommand("toggle-tiling-direction")}
        ></button>
      )}
    </div>
  );
}

/**
 * Bar component.
 *
 * Renders the while bar and is injected into the HTML.
 */
function Bar() {
  return (
    <div className="bar">
      <Left />
      <Center />
      <Right />
    </div>
  );
}
