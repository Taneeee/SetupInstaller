using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;
using Microsoft.Deployment.WindowsInstaller;

namespace MyCustomAction
{
    public class CustomActions
    {
        [CustomAction]
        public static ActionResult RunCustomAction(Session session)
        {
            session.Log("=== Begin RunCustomAction ===");

            try
            {
                // Read from CustomActionData
                string username = session.CustomActionData["USERNAME"];
                string installFolder = session.CustomActionData["INSTALLFOLDER"];

                session.Log("USERNAME: " + username);
                session.Log("INSTALLFOLDER: " + installFolder);

                string batchPath = Path.Combine(installFolder, "setup.bat");

                if (!File.Exists(batchPath))
                {
                    session.Log("Batch file not found: " + batchPath);
                    return ActionResult.Failure;
                }

                ProcessStartInfo psi = new ProcessStartInfo("cmd.exe", $"/c \"{batchPath}\" {username}")
                {
                    UseShellExecute = false,
                    CreateNoWindow = true
                };

                Process proc = Process.Start(psi);
                proc.WaitForExit();

                if (proc.ExitCode != 0)
                {
                    session.Log("Batch execution failed with exit code: " + proc.ExitCode);
                    return ActionResult.Failure;
                }

                session.Log("Batch executed successfully.");
                return ActionResult.Success;
            }
            catch (Exception ex)
            {
                session.Log("Exception in custom action: " + ex);
                return ActionResult.Failure;
            }
        }
    }
}
