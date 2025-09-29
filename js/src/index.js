import { Dialog, ICommandPalette, showDialog } from "@jupyterlab/apputils";

import { PageConfig } from "@jupyterlab/coreutils";

import { IDocumentManager } from "@jupyterlab/docmanager";

import { IFileBrowserFactory } from "@jupyterlab/filebrowser";

import { ILauncher } from "@jupyterlab/launcher";

import { request } from "requests-helper";

import "../style/index.css";

const CMD_GROUP = "Custom Commands";

async function activate(app, _docManager, palette, _browser) {
  // eslint-disable-next-line no-console
  console.log("JupyterLab extension jupyterlab_commands is activated!");

  // {
  //   const commandId = "custom:show-test-dialog";
  //
  //   jupyterapp.commands.addCommand(commandId, {
  //     label: "Show a Custom Test Dialog",
  //     isEnabled: () => true,
  //     execute: async () => {
  //       const { showDialog, Dialog } = await import("@jupyterlab/apputils");
  //       await showDialog({
  //         title: "Execute Succeeded",
  //         body: "The custom command ran successfully!",
  //         buttons: [Dialog.okButton({ label: "Awesome!" })],
  //       });
  //     },
  //   });
  //   palette.addItem({ command: commandId, category: CMD_GROUP });
  //
  //   console.log(`Command '${commandId}' was registered.`);
  // }

  {
    let commandID = "my-super-cool-toggle:toggle";
    let toggle = true; // The current toggle state
    app.commands.addCommand(commandID, {
      label: "My Super Cool Toggle",
      isToggled: function () {
        return toggle;
      },
      execute: function () {
        // Toggle the state
        toggle = !toggle;
      },
    });

    palette.addItem({
      command: commandID,
      // Sort to the top for convenience
      category: "AAA",
    });
  }

  {
    console.log("globalThis.jupyterapp", globalThis.jupyterapp);
    console.log("app", app);
    console.log("palette", palette);
  }
}

const extension = {
  activate,
  autoStart: true,
  id: "jupyterlab_commands",
  optional: [ILauncher],
  requires: [IDocumentManager, ICommandPalette, IFileBrowserFactory],
};

export default extension;
export { activate as _activate };
