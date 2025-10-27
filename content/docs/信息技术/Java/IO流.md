---
weight: 1
bookToc: true
date: 2025-02-25T18:21:00
draft: false
tags: ["Java"]
---
#### 1. 字节流（以字节为单位）
```java
// 基类: InputStream 和 OutputStream

// 文件操作
FileInputStream fis = new FileInputStream("input.txt");
FileOutputStream fos = new FileOutputStream("output.txt");

// 示例：复制文件
try (FileInputStream fis = new FileInputStream("source.txt");
     FileOutputStream fos = new FileOutputStream("target.txt")) {
    byte[] buffer = new byte[1024];
    int len;
    while ((len = fis.read(buffer)) != -1) {
        fos.write(buffer, 0, len);
    }
}

// 缓冲流：提高读写效率
try (BufferedInputStream bis = new BufferedInputStream(new FileInputStream("file.txt"));
     BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream("copy.txt"))) {
    bis.transferTo(bos); // Java 9+
}

// 数据流：读写基本数据类型
try (DataOutputStream dos = new DataOutputStream(new FileOutputStream("data.bin"))) {
    dos.writeInt(100);
    dos.writeUTF("Hello");
    dos.writeDouble(3.14);
}

// 对象流：序列化和反序列化
class User implements Serializable {
    private String name;
    private int age;
}

// 写入对象
try (ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream("user.obj"))) {
    User user = new User("张三", 25);
    oos.writeObject(user);
}

// 读取对象
try (ObjectInputStream ois = new ObjectInputStream(new FileInputStream("user.obj"))) {
    User user = (User) ois.readObject();
}
```

#### 2. 字符流（以字符为单位）
```java
// 基类: Reader 和 Writer

// 文件读写
try (FileReader fr = new FileReader("input.txt");
     FileWriter fw = new FileWriter("output.txt")) {
    char[] buffer = new char[1024];
    int len;
    while ((len = fr.read(buffer)) != -1) {
        fw.write(buffer, 0, len);
    }
}

// 缓冲字符流
try (BufferedReader br = new BufferedReader(new FileReader("file.txt"))) {
    String line;
    while ((line = br.readLine()) != null) {
        System.out.println(line);
    }
}

// 字符串读写
StringReader sr = new StringReader("Hello World");
StringWriter sw = new StringWriter();
```

#### 3. 转换流（字节流转字符流）
```java
// InputStreamReader：字节流转换为字符流
try (InputStreamReader isr = new InputStreamReader(new FileInputStream("file.txt"), "UTF-8")) {
    char[] buffer = new char[1024];
    int len;
    while ((len = isr.read(buffer)) != -1) {
        System.out.print(new String(buffer, 0, len));
    }
}

// OutputStreamWriter：字符流转换为字节流
try (OutputStreamWriter osw = new OutputStreamWriter(new FileOutputStream("file.txt"), "UTF-8")) {
    osw.write("你好，世界");
}
```

#### 4. 实际应用场景

文件复制：
```java
public static void copyFile(String source, String target) {
    try (FileInputStream fis = new FileInputStream(source);
         FileOutputStream fos = new FileOutputStream(target)) {
        byte[] buffer = new byte[8192];
        int len;
        while ((len = fis.read(buffer)) != -1) {
            fos.write(buffer, 0, len);
        }
    } catch (IOException e) {
        e.printStackTrace();
    }
}
```

文本文件读取：
```java
public static List<String> readLines(String filename) {
    List<String> lines = new ArrayList<>();
    try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
        String line;
        while ((line = br.readLine()) != null) {
            lines.add(line);
        }
    } catch (IOException e) {
        e.printStackTrace();
    }
    return lines;
}
```

大文件处理：
```java
public static void processLargeFile(String filename) {
    try (BufferedReader br = new BufferedReader(
            new FileReader(filename), 8192)) { // 设置更大的缓冲区
        String line;
        while ((line = br.readLine()) != null) {
            // 处理每一行
            processLine(line);
        }
    } catch (IOException e) {
        e.printStackTrace();
    }
}
```

#### 常见使用建议
1. 总是使用try-with-resources来确保资源正确关闭
2. 处理文本文件优先使用字符流
3. 处理二进制文件使用字节流
4. 大文件操作使用缓冲流提高性能
5. 注意指定正确的字符编码

#### IO流关系图
```
InputStream (字节输入流)
├── FileInputStream（文件输入流）
├── BufferedInputStream（带缓冲）
├── DataInputStream（数据输入流）
└── ObjectInputStream（对象输入流）

OutputStream (字节输出流)
├── FileOutputStream（文件输出流）
├── BufferedOutputStream（带缓冲）
├── DataOutputStream（数据输出流）
└── ObjectOutputStream（对象输出流）

Reader (字符输入流)
├── FileReader（文件读取）
├── BufferedReader（带缓冲）
├── InputStreamReader（转换流）
└── StringReader（字符串输入流）

Writer (字符输出流)
├── FileWriter（文件写入）
├── BufferedWriter（带缓冲）
├── OutputStreamWriter（转换流）
└── StringWriter（字符串输出流）
```


#### 解压缩示例
##### 1. ZIP文件操作
```java
// 压缩文件/目录
public static void zip(String sourcePath, String zipPath) {
    try (ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(zipPath))) {
        Path sourceDir = Paths.get(sourcePath);
        Files.walk(sourceDir)
            .filter(path -> !Files.isDirectory(path))
            .forEach(path -> {
                ZipEntry zipEntry = new ZipEntry(sourceDir.relativize(path).toString());
                try {
                    zos.putNextEntry(zipEntry);
                    Files.copy(path, zos);
                    zos.closeEntry();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            });
    } catch (IOException e) {
        e.printStackTrace();
    }
}

// 解压ZIP文件
public static void unzip(String zipPath, String destPath) {
    try (ZipInputStream zis = new ZipInputStream(new FileInputStream(zipPath))) {
        ZipEntry zipEntry;
        while ((zipEntry = zis.getNextEntry()) != null) {
            Path destFile = Paths.get(destPath, zipEntry.getName());
            if (zipEntry.isDirectory()) {
                Files.createDirectories(destFile);
            } else {
                Files.createDirectories(destFile.getParent());
                Files.copy(zis, destFile, StandardCopyOption.REPLACE_EXISTING);
            }
            zis.closeEntry();
        }
    } catch (IOException e) {
        e.printStackTrace();
    }
}
```

##### 2. GZIP文件操作
```java
// 压缩文件
public static void gzip(String sourcePath, String gzipPath) {
    try (GZIPOutputStream gos = new GZIPOutputStream(new FileOutputStream(gzipPath));
         FileInputStream fis = new FileInputStream(sourcePath)) {
        byte[] buffer = new byte[1024];
        int len;
        while ((len = fis.read(buffer)) != -1) {
            gos.write(buffer, 0, len);
        }
    } catch (IOException e) {
        e.printStackTrace();
    }
}

// 解压GZIP文件
public static void ungzip(String gzipPath, String destPath) {
    try (GZIPInputStream gis = new GZIPInputStream(new FileInputStream(gzipPath));
         FileOutputStream fos = new FileOutputStream(destPath)) {
        byte[] buffer = new byte[1024];
        int len;
        while ((len = gis.read(buffer)) != -1) {
            fos.write(buffer, 0, len);
        }
    } catch (IOException e) {
        e.printStackTrace();
    }
}
```

3. tar.gz文件操作（需要引入Apache Commons Compress）：
```xml
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-compress</artifactId>
    <version>1.24.0</version>
</dependency>
```

```java
// 解压tar.gz文件
public static void untargz(String targzPath, String destPath) {
    try (FileInputStream fis = new FileInputStream(targzPath);
         GZIPInputStream gis = new GZIPInputStream(fis);
         TarArchiveInputStream tais = new TarArchiveInputStream(gis)) {
        
        TarArchiveEntry entry;
        while ((entry = tais.getNextTarEntry()) != null) {
            Path destFile = Paths.get(destPath, entry.getName());
            if (entry.isDirectory()) {
                Files.createDirectories(destFile);
            } else {
                Files.createDirectories(destFile.getParent());
                Files.copy(tais, destFile, StandardCopyOption.REPLACE_EXISTING);
            }
        }
    } catch (IOException e) {
        e.printStackTrace();
    }
}
```

4. 实际应用示例：

压缩指定目录下的所有文件：
```java
public static void zipDirectory(String sourceDir, String zipFile) {
    Path sourcePath = Paths.get(sourceDir);
    try (ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(zipFile))) {
        Files.walkFileTree(sourcePath, new SimpleFileVisitor<Path>() {
            @Override
            public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                String relativePath = sourcePath.relativize(file).toString();
                ZipEntry zipEntry = new ZipEntry(relativePath);
                zos.putNextEntry(zipEntry);
                Files.copy(file, zos);
                zos.closeEntry();
                return FileVisitResult.CONTINUE;
            }
        });
    } catch (IOException e) {
        e.printStackTrace();
    }
}
```

批量解压文件：
```java
public static void batchUnzip(String zipDir, String destDir) {
    try {
        Files.walk(Paths.get(zipDir))
            .filter(path -> path.toString().endsWith(".zip"))
            .forEach(zipFile -> {
                String destPath = Paths.get(destDir, 
                    zipFile.getFileName().toString().replace(".zip", "")).toString();
                unzip(zipFile.toString(), destPath);
            });
    } catch (IOException e) {
        e.printStackTrace();
    }
}
```

使用建议：
1. 处理大文件时使用缓冲流
2. 注意字符编码问题，特别是中文文件名
3. 处理压缩文件时注意关闭资源
4. 考虑使用进度监听器
5. 预防路径穿越漏洞

示例使用：
```java
public static void main(String[] args) {
    // 压缩文件夹
    zip("D:/documents", "D:/backup.zip");
    
    // 解压文件
    unzip("D:/backup.zip", "D:/restore");
    
    // 压缩单个文件
    gzip("D:/test.txt", "D:/test.txt.gz");
    
    // 解压gz文件
    ungzip("D:/test.txt.gz", "D:/test_restored.txt");
    
    // 批量处理
    batchUnzip("D:/zips", "D:/extracted");
}
```

补充说明：
- ZIP格式支持多文件压缩
- GZIP通常用于单个文件压缩
- tar.gz在Linux系统中较常见
- 对于大文件压缩，考虑使用异步处理