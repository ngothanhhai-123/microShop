package com.microshop.dao;

import com.microshop.context.DBContext;
import com.microshop.model.DanhMuc;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;


// ahihihihihi
public class DanhMucDAO implements ReadOnlyDAO<DanhMuc, Integer> {

    private DanhMuc mapResultSetToDanhMuc(ResultSet rs) throws SQLException {
        DanhMuc dm = new DanhMuc();
        dm.setMaDanhMuc(rs.getObject("MaDanhMuc", Integer.class));
        dm.setTenDanhMuc(rs.getString("TenDanhMuc"));
        return dm;
    }

    private Connection getConnection() throws SQLException {
        return DBContext.getConnection();
    }

    @Override
    public List<DanhMuc> getAll() throws SQLException { 
        List<DanhMuc> list = new ArrayList<>();
        String sql = "SELECT * FROM DANHMUC";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToDanhMuc(rs));
            }
        }
     
        return list;
    }

    @Override
    public DanhMuc getById(Integer id) throws SQLException {
        DanhMuc result = null;
        String sql = "SELECT * FROM DANHMUC WHERE MaDanhMuc = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setObject(1, id); 

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    result = mapResultSetToDanhMuc(rs);
                }
            }
        }
    
        return result;
    }

    // Đã chỉnh sửa by Hưng
    // Xóa các hàm insert, update, delete (vi phạm yêu cầu ReadOnlyDAO)
    // Xóa hàm getByPrefix (không được yêu cầu)
    // Implement lại theo yêu cầu
    // Sửa hết try-catch thành throws để cho servlet xử lý
    // dùng getObject/setObject thay cho getInt/setInt cũ để xử lý null
}
