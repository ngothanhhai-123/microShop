package com.microshop.demo;
import java.security.MessageDigest;
//SpotBugs có các rule mặc định báo đỏ ngay khi thấy MD5 hoặc DES.
public class Demo04_WeakCrypto_SpotBugs {
    public byte[] hashData(String input) {
        try {
            // LỖI: Sử dụng MD5 là thuật toán đã bị bẻ khóa
            MessageDigest md = MessageDigest.getInstance("MD5");
            return md.digest(input.getBytes());
        } catch (Exception e) { return null; }
    }
}