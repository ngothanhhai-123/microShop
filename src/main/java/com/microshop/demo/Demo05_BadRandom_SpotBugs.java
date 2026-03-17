package com.microshop.demo;
import java.util.Random;
//Tạo token reset mật khẩu nhưng dùng hàm Random cơ bản thay vì SecureRandom.
public class Demo05_BadRandom_SpotBugs {
    public String generateResetToken() {
        try {
            // LỖI: java.util.Random có thể đoán trước được hạt giống (seed)
            Random rand = new Random();
            return "TOKEN-" + rand.nextInt(999999);
        } catch (Exception e) { return null; }
    }
}