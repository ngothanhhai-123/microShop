package com.microshop.dao;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
//w
import java.sql.Statement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;

import com.microshop.context.DBContext;
import com.microshop.model.AnhTaiKhoan;

@ExtendWith(MockitoExtension.class)
class AnhTaiKhoanDAOTest {

    @Mock
    private Connection connection;
    @Mock
    private PreparedStatement ps;
    @Mock
    private ResultSet rs;
    @Mock
    private ResultSet generatedKeysRs;

    @InjectMocks
    private AnhTaiKhoanDAO anhTaiKhoanDAO;

    private void mockDatabaseConnection() throws SQLException {
        when(connection.prepareStatement(anyString())).thenReturn(ps);
    }

    private void mockDatabaseConnectionWithKeys() throws SQLException {
        when(connection.prepareStatement(anyString(), eq(Statement.RETURN_GENERATED_KEYS))).thenReturn(ps);
    }

    @Test
    void getByMaTaiKhoan_ReturnsList() throws SQLException {
        // Arrange
        try (MockedStatic<DBContext> mockedDBContext = Mockito.mockStatic(DBContext.class)) {
            mockedDBContext.when(DBContext::getConnection).thenReturn(connection);
            mockDatabaseConnection();

            when(ps.executeQuery()).thenReturn(rs);
            when(rs.next()).thenReturn(true).thenReturn(true).thenReturn(false); // 2 ảnh

            // SỬA: Mock rs.getObject
            when(rs.getObject("MaAnh", Integer.class)).thenReturn(10).thenReturn(11);
            when(rs.getObject("MaTaiKhoan", Integer.class)).thenReturn(1).thenReturn(1);

            // Act
            List<AnhTaiKhoan> result = anhTaiKhoanDAO.getByMaTaiKhoan(1);

            // Assert
            assertNotNull(result);
            assertEquals(2, result.size());

            // SỬA: Verify ps.setObject
            verify(ps).setObject(1, 1);
        }
    }

    @Test
    void getByMaTaiKhoan_ThrowsSQLException() throws SQLException {
        // (Không cần thay đổi)
        try (MockedStatic<DBContext> mockedDBContext = Mockito.mockStatic(DBContext.class)) {
            mockedDBContext.when(DBContext::getConnection).thenReturn(connection);
            mockDatabaseConnection();

            when(ps.executeQuery()).thenThrow(new SQLException("Test DB Error"));

            // Act & Assert
            assertThrows(SQLException.class, () -> {
                anhTaiKhoanDAO.getByMaTaiKhoan(1);
            });
        }
    }

    @Test
    void insert_ReturnsGeneratedId() throws SQLException {
        // Arrange
        try (MockedStatic<DBContext> mockedDBContext = Mockito.mockStatic(DBContext.class)) {
            mockedDBContext.when(DBContext::getConnection).thenReturn(connection);
            mockDatabaseConnectionWithKeys();

            when(ps.executeUpdate()).thenReturn(1);
            when(ps.getGeneratedKeys()).thenReturn(generatedKeysRs);
            when(generatedKeysRs.next()).thenReturn(true);
            when(generatedKeysRs.getInt(1)).thenReturn(101); // MaAnh mới

            AnhTaiKhoan newImg = new AnhTaiKhoan(null, 1, "path/to/img.jpg");

            // Act
            Integer newId = anhTaiKhoanDAO.insert(newImg);

            // Assert
            assertNotNull(newId);
            assertEquals(101, newId);

            // SỬA: Verify ps.setObject
            verify(ps).setObject(1, 1);
            verify(ps).setString(2, "path/to/img.jpg");
        }
    }

    @Test
    void deleteByMaAnh_ReturnsTrue() throws SQLException {
        // Arrange
        try (MockedStatic<DBContext> mockedDBContext = Mockito.mockStatic(DBContext.class)) {
            mockedDBContext.when(DBContext::getConnection).thenReturn(connection);
            mockDatabaseConnection();

            when(ps.executeUpdate()).thenReturn(1); // 1 hàng bị xóa

            // Act
            boolean success = anhTaiKhoanDAO.deleteByMaAnh(101);

            // Assert
            assertTrue(success);

            // SỬA: Verify ps.setObject
            verify(ps).setObject(1, 101);
        }
    }

    @Test
    void deleteByMaTaiKhoan_ReturnsTrue() throws SQLException {
        // Arrange
        try (MockedStatic<DBContext> mockedDBContext = Mockito.mockStatic(DBContext.class)) {
            mockedDBContext.when(DBContext::getConnection).thenReturn(connection);
            mockDatabaseConnection();

            when(ps.executeUpdate()).thenReturn(3); // 3 hàng bị xóa

            // Act
            boolean success = anhTaiKhoanDAO.deleteByMaTaiKhoan(1);

            // Assert
            assertTrue(success); // executeUpdate > 0 là true

            // SỬA: Verify ps.setObject
            verify(ps).setObject(1, 1);
        }
    }
}
