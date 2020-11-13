package com.capstones.luaext;

import android.os.Build;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileFilter;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.util.regex.Pattern;

public class AndroidDeviceInfo {
    private static String run(String[] cmd, String workdirectory) throws IOException {
        String result = "";
        try {
            ProcessBuilder builder = new ProcessBuilder(cmd);
            InputStream in = null;
            if (workdirectory != null) {
                builder.directory(new File(workdirectory));
                builder.redirectErrorStream(true);
                in = builder.start().getInputStream();
                if (in != null) {
                    byte[] re = new byte[1024];
                    while (in.read(re) != -1) {
                        result = result + new String(re);
                    }
                }
            }
            if (in != null) {
                in.close();
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return result;
    }

    public static String GetCpuName() {
        try {
            BufferedReader br = new BufferedReader(new FileReader("/proc/cpuinfo"));
            String text = br.readLine();
            br.close();
            return text.split(":\\s+", 2)[1];
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e2) {
            e2.printStackTrace();
        }
        return null;
    }

    public static String GetMaxCpuFreq() {
        String result = "";
        int coreNum = GetCpuCoresNum();
        String str = "";
        try {
            StringBuffer cpuOnlineFilePath = new StringBuffer();
            StringBuffer cpufreqFilePath = new StringBuffer();
            for (int i = 0; i < coreNum; i++) {
                cpuOnlineFilePath.append("/sys/devices/system/cpu/cpu");
                cpuOnlineFilePath.append(i);
                cpuOnlineFilePath.append("/online");
                String[] args1 = {"/system/bin/cat", cpuOnlineFilePath.toString()};
                cpuOnlineFilePath.setLength(0);
                if (run(args1, "/system/bin/").trim().equals("1")) {
                    cpufreqFilePath.append("/sys/devices/system/cpu/cpu");
                    cpufreqFilePath.append(i);
                    cpufreqFilePath.append("/cpufreq/cpuinfo_max_freq");
                    String[] args = {"/system/bin/cat", cpufreqFilePath.toString()};
                    cpufreqFilePath.setLength(0);
                    result = result + run(args, "/system/bin/").trim() + ":";
                }
            }
        } catch (IOException ex) {
            ex.printStackTrace();
        }
        return result.length() > 0 ? result.substring(0, result.length() - 1) : result;
    }

    public static String GetMinCpuFreq() {
        String result = "";
        int coreNum = GetCpuCoresNum();
        String str = "";
        try {
            StringBuffer cpuOnlineFilePath = new StringBuffer();
            StringBuffer cpufreqFilePath = new StringBuffer();
            for (int i = 0; i < coreNum; i++) {
                cpuOnlineFilePath.append("/sys/devices/system/cpu/cpu");
                cpuOnlineFilePath.append(i);
                cpuOnlineFilePath.append("/online");
                String[] args1 = {"/system/bin/cat", cpuOnlineFilePath.toString()};
                cpuOnlineFilePath.setLength(0);
                if (run(args1, "/system/bin/").trim().equals("1")) {
                    cpufreqFilePath.append("/sys/devices/system/cpu/cpu");
                    cpufreqFilePath.append(i);
                    cpufreqFilePath.append("/cpufreq/cpuinfo_min_freq");
                    String[] args = {"/system/bin/cat", cpufreqFilePath.toString()};
                    cpufreqFilePath.setLength(0);
                    result = result + run(args, "/system/bin/").trim() + ":";
                }
            }
        } catch (IOException ex) {
            ex.printStackTrace();
        }
        return result.length() > 0 ? result.substring(0, result.length() - 1) : result;
    }

    public static String GetCurCpuFreq() {
        String result = "";
        int coreNum = GetCpuCoresNum();
        String str = "";
        try {
            StringBuffer cpuOnlineFilePath = new StringBuffer();
            StringBuffer cpufreqFilePath = new StringBuffer();
            for (int i = 0; i < coreNum; i++) {
                cpuOnlineFilePath.append("/sys/devices/system/cpu/cpu");
                cpuOnlineFilePath.append(i);
                cpuOnlineFilePath.append("/online");
                String[] args1 = {"/system/bin/cat", cpuOnlineFilePath.toString()};
                cpuOnlineFilePath.setLength(0);
                if (run(args1, "/system/bin/").trim().equals("1")) {
                    cpufreqFilePath.append("/sys/devices/system/cpu/cpu");
                    cpufreqFilePath.append(i);
                    cpufreqFilePath.append("/cpufreq/scaling_cur_freq");
                    String[] args = {"/system/bin/cat", cpufreqFilePath.toString()};
                    cpufreqFilePath.setLength(0);
                    result = result + run(args, "/system/bin/").trim() + ":";
                }
            }
        } catch (IOException ex) {
            ex.printStackTrace();
        }
        return result.length() > 0 ? result.substring(0, result.length() - 1) : result;
    }

    public static int GetCpuKernel() {
        String result = null;
        try {
            result = run(new String[]{"/system/bin/cat", "/sys/devices/system/cpu/kernel_max"}, "/system/bin/");
        } catch (IOException ex) {
            ex.printStackTrace();
        }
        return Integer.valueOf(result.trim()).intValue() + 1;
    }

    public static int GetCpuCoresNum() {
        try {
            return new File("/sys/devices/system/cpu/").listFiles(new FileFilter() {
                public boolean accept(File pathname) {
                    if (Pattern.matches("cpu[0-9]", pathname.getName())) {
                        return true;
                    }
                    return false;
                }
            }).length;
        } catch (Exception e) {
            e.printStackTrace();
            return 1;
        }
    }

    public static double GetMemTotal() {
        String result = null;
        String str = "";
        try {
            BufferedReader localBufferedReader = new BufferedReader(new FileReader("/proc/meminfo"), 8192);
            while (true) {
                String readLine = localBufferedReader.readLine();
                if (readLine == null) {
                    break;
                }
                String[] lineStr = readLine.split(":\\s+");
                if (lineStr[0].equals("MemTotal")) {
                    result = lineStr[1].split(" ")[0];
                    break;
                }
            }
            localBufferedReader.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return Double.valueOf(result).doubleValue() / 1048576.0d;
    }

    public static String GetABI() {
        return Build.CPU_ABI;
    }
}
