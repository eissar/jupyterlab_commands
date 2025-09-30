import { Dialog, ICommandPalette, showDialog } from "@jupyterlab/apputils";
import { JupyterFrontEnd } from "@jupyterlab/application";

import { PageConfig } from "@jupyterlab/coreutils";

import { IDocumentManager } from "@jupyterlab/docmanager";

import { IFileBrowserFactory } from "@jupyterlab/filebrowser";

import { ILauncher } from "@jupyterlab/launcher";

import { request } from "requests-helper";

import "../style/index.css";

// In your extension
class MyKernelExtension {
  constructor() {
    this.setupKernelHooks();
  }

  setupKernelHooks() {
    // Hook into kernel creation
    console.log(JupyterFrontEnd);
    // JupyterFrontEnd.getInstance().serviceManager.kernelspecs.kernelSpecsChanged.connect(
    //   () => {
    //     this.patchKernels();
    //   },
    // );
  }

  async patchKernels() {
    const kernelManager = JupyterFrontEnd.getInstance().serviceManager.kernels;

    // Override kernel creation
    const originalStartNew = kernelManager.startNew.bind(kernelManager);
    kernelManager.startNew = async (options) => {
      const kernel = await originalStartNew(options);
      this.patchKernel(kernel);
      return kernel;
    };
  }

  patchKernel(kernel) {
    // Hook into kernel configuration
    const originalConfigure = kernel._configure?.bind(kernel);

    if (originalConfigure) {
      kernel._configure = async (settings) => {
        console.log("Intercepting kernel configuration", settings);

        // Your custom logic here
        await this.customConfiguration(kernel, settings);

        // Call original
        return originalConfigure(settings);
      };
    }
  }

  async customConfiguration(kernel, settings) {
    // Add your custom configuration
    // Example: Inject environment variables, modify kernel args, etc.
    console.log("Custom kernel configuration for:", kernel.name);
  }
}

const CMD_GROUP = "Custom Commands";

async function activate(app, _docManager, palette, _browser) {
  new MyKernelExtension();

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
