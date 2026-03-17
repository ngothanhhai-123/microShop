package com.microshop.demo;
import java.io.*;
//Cả công cụ tĩnh (Codacy) và động (ZAP - qua payload serialize) đều có thể bắt lỗi này.
public class Demo09_Deserialization_Codacy {
    public void readUserData(InputStream inputStream) {
        try {
            ObjectInputStream in = new ObjectInputStream(inputStream);
            // LỖI: Đọc Object trực tiếp mà không kiểm tra cấu trúc
            Object obj = in.readObject();
        } catch (Exception e) {}
    }
}