package com.microshop.demo;
import java.sql.*;
//PMD và SpotBugs sẽ quét và chửi bới việc mở CSDL mà không có khối finally để đóng Connection.
public class Demo03_ResourceLeak_PMD {
    public void getGameData() {
        try {
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/microshop", "root", "");
            Statement st = conn.createStatement();
            ResultSet rs = st.executeQuery("SELECT * FROM game_steam");
            // LỖI: Quên không close() Connection và ResultSet, gây cạn kiệt tài nguyên server
        } catch (Exception e) {}
    }
}