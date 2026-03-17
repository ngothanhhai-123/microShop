package com.microshop.demo;
import java.net.URL;

public class Demo08_SSRF_Codacy {
    public void fetchExternalData(String userProvidedUrl) {
        try {
            // LỖI: Server thay mặt người dùng gọi đến 1 URL bất kỳ (có thể là server nội bộ)
            new URL(userProvidedUrl).openConnection().getInputStream();
        } catch (Exception e) {}
    }
}