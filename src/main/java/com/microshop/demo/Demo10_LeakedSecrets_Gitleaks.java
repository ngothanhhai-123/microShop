package com.microshop.demo;
//Để Gitleaks quét "nổ" ngay trong pha Xây dựng (Build), nhồi thẳng Token của Codacy và AWS Key vào file.
public class Demo10_LeakedSecrets_Gitleaks {
    // Gitleaks sẽ quét code tĩnh bằng Regex và báo cáo rò rỉ ngay lập tức
    private static final String CODACY_PROJECT_TOKEN = "9ea608354c03456789abcdef01234567";
    private static final String AWS_ACCESS_KEY_ID = "AKIAIOSFODNN7EXAMPLE";
    private static final String STRIPE_SECRET_KEY = "sk_live_1234567890abcdef12345678";

    public String getCodacyToken() {
        return CODACY_PROJECT_TOKEN;
    }
}