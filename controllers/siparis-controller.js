const connection = require("../service/connection.js");

exports.siparisleriGetir = async (req, res) => {
    connection.query("SELECT * FROM siparisler", (error, data) => {
        if (error) return res.status(500).json({ message: error });
        if (data.length === 0) {
            return res.status(404).json({ error: "Sipariş bulunamadı." });
        }
        return res.json(data);
    });
};

exports.siparisOlustur = async (req, res) => {
    const q = `INSERT INTO siparisler (musteri_id, urun_id, siparis_tarihi, teslim_tarihi, siparis_durumu) VALUES (?)`;
    const values = [
        req.body.musteri_id,
        req.body.urun_id,
        req.body.siparis_tarihi,
        req.body.teslim_tarihi,
        req.body.siparis_durumu,
    ];
    connection.query(q, [values], (error, data) => {
        if (error) return res.status(500).json({ message: error });
        return res.json("Sipariş başarıyla oluşturuldu.");
    });
}

exports.siparisGuncelle = async (req, res) => {
    const id = req.params.id;
    const values = req.body;
    const q = "UPDATE siparisler SET ? WHERE id = ?";
    connection.query(q, [values, id], (error, data) => {
        if (error) return res.status(500).json({ message: error });
        if (data.affectedRows === 0) {
            return res.status(404).json({ error: "Sipariş bulunamadı." });
        }
        return res
            .status(200)
            .json({ message: "Sipariş başarıyla güncellendi." });
    });
};

exports.tekSiparisGetir = async (req, res) => {
    const id = req.params.id;
    const q = "SELECT * FROM siparisler WHERE id = ?";
    connection.query(q, [id], (error, data) => {
        if (error) return res.status(500).json({ message: error });
        if (data.length === 0) {
            return res.status(404).json({ error: "Sipariş bulunamadı." });
        }
        return res.json(data);
    });
}

exports.siparisSil = async (req, res) => {
    const id = req.params.id;
    const q = "DELETE FROM siparisler WHERE id = ?";
    connection.query(q, [id], (error, data) => {
        if (error) return res.status(500).json({ message: error });
        if (data.affectedRows === 0) {
            return res.status(404).json({ error: "Sipariş bulunamadı." });
        }
        return res
            .status(200)
            .json({ message: "Sipariş başarıyla silindi." });
    });
}

exports.siparisleriFiltrele = async (req, res) => {
    const keyword = req.params.keyword;
    const q = `SELECT * FROM siparisler 
    WHERE musteri_id LIKE '%${keyword}%' 
    OR urun_id LIKE '%${keyword}%' 
    OR siparis_tarihi LIKE '%${keyword}%' 
    OR teslim_tarihi LIKE '%${keyword}%' 
    OR siparis_durumu LIKE '%${keyword}%'`;
    connection.query(q, (error, data) => {
        if (error) return res.status(500).json({ message: error });
        if (data.length === 0) {
            return res.status(404).json({ error: "Sipariş bulunamadı." });
        }
        return res.json(data);
    });
}
