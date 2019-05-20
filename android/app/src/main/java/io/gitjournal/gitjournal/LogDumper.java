package io.gitjournal.gitjournal;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;

public class LogDumper {
    public static void dumpLogs(String filePath) throws Exception {
        File file = new File(filePath);

        // Truncate the existing file
        PrintWriter pw = new PrintWriter(file);
        pw.close();

        FileOutputStream stream = new FileOutputStream(file, true);

        Process logcat = Runtime.getRuntime().exec(new String[]{"logcat", "-d"});
        BufferedReader br = new BufferedReader(new InputStreamReader(logcat.getInputStream()), 4 * 1024);
        String line;
        String separator = System.getProperty("line.separator");
        while ((line = br.readLine()) != null) {
            stream.write(line.getBytes());
            stream.write(separator.getBytes());
        }
        stream.close();
    }
}
