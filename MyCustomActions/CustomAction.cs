using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Threading;
using Microsoft.Deployment.WindowsInstaller;
using System.IO.Compression;

namespace MyCustomActions
{
    public class CustomActions
    {
        [CustomAction]
        public static ActionResult LaunchBatchWithHostname(Session session)
        {
            session.Log("Begin LaunchBatchWithHostname");

            try
            {
                // Parse CustomActionData
                string data = session.CustomActionData.ToString();
                session.Log($"CustomActionData: {data}");

                Dictionary<string, string> props = ParseCustomActionData(data);
                if (!props.TryGetValue("HOSTNAME", out string hostname))
                {
                    session.Log("HOSTNAME not found in CustomActionData.");
                    return ActionResult.Failure;
                }

                // Hardcoded batch file path
                // string batchPath = @"D:\Users\aachaudh\source\repos\SetupInstaller\install-connector-WinMsi.bat";


                // Thread.Sleep(5000);
                //if (!props.TryGetValue("INSTALLFOLDER", out string installFolder))
                //{
                //    session.Log("INSTALLFOLDER not found in CustomActionData.");
                //    return ActionResult.Failure;
                //}

                // string batchPath = Path.Combine(installFolder, "install-connector-WinMsi.bat");

                string msiPath = session.CustomActionData["INSTALLERDIR"];
                string msiDir = Path.GetDirectoryName(msiPath);

                session.Log("Original MSI location: " + msiDir);

                string batchPath = Path.Combine(msiDir, "install-connector-WinMsi.bat");
                session.Log(batchPath);
                if (!File.Exists(batchPath))
                {
                    session.Log($"Batch file not found: {batchPath}");
                    return ActionResult.Failure;
                }

                //string zipPath = Path.Combine(installFolder, "BMC-DevTools.zip");
                //string extractPath = installFolder;

                //string psCommand = $"Expand-Archive -Path '{zipPath}' -DestinationPath '{extractPath}' -Force";

                //ProcessStartInfo psin = new ProcessStartInfo
                //{
                //    FileName = "powershell.exe",
                //    Arguments = $"-NoProfile -ExecutionPolicy Bypass -Command \"{psCommand}\"",
                //    CreateNoWindow = true,
                //    UseShellExecute = false,
                //    RedirectStandardOutput = true,
                //    RedirectStandardError = true
                //};

                //session.Log("Unzipping using PowerShell...");

                //using (Process psProc = Process.Start(psin))
                //{
                //    string output = psProc.StandardOutput.ReadToEnd();
                //    string errors = psProc.StandardError.ReadToEnd();
                //    psProc.WaitForExit();

                //    session.Log("PowerShell output: " + output);
                //    if (!string.IsNullOrEmpty(errors))
                //        session.Log("PowerShell errors: " + errors);

                //    if (psProc.ExitCode != 0)
                //        return ActionResult.Failure;
                //}
                string arguments = $"/C \"\"{batchPath}\" \"{hostname}\"\"";

                session.Log($"Running: cmd.exe {arguments}");
                Thread.Sleep(5000);
                ProcessStartInfo psi = new ProcessStartInfo
                {
                    FileName = "cmd.exe",
                    Arguments = arguments,
                    WorkingDirectory = Path.GetDirectoryName(batchPath),
                    CreateNoWindow = true,
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true
                };

                using (Process proc = Process.Start(psi))
                {
                    string stdout = proc.StandardOutput.ReadToEnd();
                    string stderr = proc.StandardError.ReadToEnd();

                    proc.WaitForExit();

                    session.Log($"Batch output: {stdout}");
                    if (!string.IsNullOrEmpty(stderr))
                        session.Log($"Batch errors: {stderr}");

                    if (proc.ExitCode != 0)
                    {
                        session.Log($"Batch file exited with code {proc.ExitCode}");
                        return ActionResult.Failure;
                    }
                }

                session.Log("Batch file executed successfully.");
                return ActionResult.Success;
            }
            catch (Exception ex)
            {
                session.Log($"Exception: {ex}");
                return ActionResult.Failure;
            }
        }

        private static Dictionary<string, string> ParseCustomActionData(string data)
        {
            var result = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            var pairs = data.Split(';');
            foreach (var pair in pairs)
            {
                var parts = pair.Split(new[] { '=' }, 2);
                if (parts.Length == 2)
                    result[parts[0]] = parts[1];
            }
            return result;
        }


        [CustomAction]
        public static ActionResult LaunchUninstallBatch(Session session)
        {
            session.Log("Begin LaunchUninstallBatch");

            try
            {
                // Access directly from session.CustomActionData
                //if (!session.CustomActionData.TryGetValue("INSTALLFOLDER", out string installFolder))
                //{
                //    session.Log("INSTALLFOLDER not found in CustomActionData.");
                //    return ActionResult.Failure;
                //}

                //string tempPath = @"D:\Users\aachaudh\source\repos\SetupInstaller\uninstall.bat";

                string msiPath = session.CustomActionData["INSTALLERDIR"];
                string msiDir = Path.GetDirectoryName(msiPath);

                session.Log("Original MSI location: " + msiDir);

                string tempPath = Path.Combine(msiDir, "uninstall.bat");

                ProcessStartInfo psi = new ProcessStartInfo
                {
                    FileName = "cmd.exe",
                    Arguments = $"/C \"{tempPath}\"",
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true
                };

                using (Process proc = Process.Start(psi))
                {
                    string stdout = proc.StandardOutput.ReadToEnd();
                    string stderr = proc.StandardError.ReadToEnd();
                    proc.WaitForExit();

                    session.Log("Uninstall batch output: " + stdout);
                    if (!string.IsNullOrEmpty(stderr))
                        session.Log("Uninstall batch errors: " + stderr);

                    if (proc.ExitCode != 0)
                    {
                        session.Log($"Uninstall batch exited with code {proc.ExitCode}");
                        return ActionResult.Failure;
                    }
                }

                session.Log("Uninstall batch executed successfully.");
                return ActionResult.Success;
            }
            catch (Exception ex)
            {
                session.Log($"Exception in LaunchUninstallBatch: {ex}");
                return ActionResult.Failure;
            }
        }

        //[CustomAction]
        //public static ActionResult LaunchBatchWithHostname(Session session)
        //{
        //    try
        //    {
        //        session.Log("Begin LaunchBatchWithHostname");

        //        var data = session.CustomActionData;
        //        var hostname = data["HOSTNAME"];
        //        var installFolder = data["INSTALLFOLDER"];
        //        // var batchPath = @"C:\Program Files (x86)\SetupInstaller\install-connector-WinMsi.bat";
        //        // var batchPath = Path.Combine(installFolder, "install-connector-WinMsi.bat");
        //        string sourcePath = Path.Combine(installFolder, "install-connector-WinMsi.bat");
        //        string tempPath = Path.Combine(Path.GetTempPath(), "install-connector-WinMsi.bat");

        //        // Copy to temp
        //        File.Copy(sourcePath, tempPath, true);
        //        session.Log($"Batch path: {tempPath}");
        //        session.Log($"Hostname: {hostname}");

        //        if (!File.Exists(tempPath))
        //        {
        //            session.Log($"ERROR: Batch file not found at {tempPath}");
        //            return ActionResult.Failure;
        //        }
        //        Thread.Sleep(10000);
        //        var psi = new ProcessStartInfo
        //        {
        //            FileName = "cmd.exe",
        //            Arguments = $"/C \"{tempPath}\" \"{hostname}\"",
        //            UseShellExecute = false,
        //            CreateNoWindow = true,
        //            RedirectStandardOutput = true,
        //            RedirectStandardError = true
        //        };

        //        var proc = Process.Start(psi);
        //        proc.WaitForExit();

        //        session.Log("Batch script executed.");
        //        return proc.ExitCode == 0 ? ActionResult.Success : ActionResult.Failure;
        //    }
        //    catch (Exception ex)
        //    {
        //        session.Log("Exception in LaunchBatchWithHostname: " + ex.ToString());
        //        return ActionResult.Failure;
        //    }
        //}

    }
}
