package services

import (
	"fmt"
	"net/smtp"
	"os"
)

const (
	smtpHost = "smtp.gmail.com"
	smtpPort = "587"
)

func getSMTPConfig() (string, string, string, string, error) {
	senderEmail := os.Getenv("SMTP_SENDER_EMAIL")
	senderPass := os.Getenv("SMTP_SENDER_PASSWORD")
	host := os.Getenv("SMTP_HOST")
	port := os.Getenv("SMTP_PORT")

	if senderEmail == "" || senderPass == "" {
		return "", "", "", "", fmt.Errorf("SMTP credentials belum dikonfigurasi. Set SMTP_SENDER_EMAIL dan SMTP_SENDER_PASSWORD")
	}
	if host == "" {
		host = smtpHost
	}
	if port == "" {
		port = smtpPort
	}
	return host, port, senderEmail, senderPass, nil
}

// Fungsi untuk mengirim email OTP
func KirimEmailOTP(tujuanEmail string, kodeOTP string) error {
	host, port, senderEmail, senderPass, err := getSMTPConfig()
	if err != nil {
		return err
	}

	// Otentikasi ke server SMTP
	auth := smtp.PlainAuth("", senderEmail, senderPass, host)

	// Membuat format isi email (Kita pakai HTML agar tampilannya cantik seperti startup)
	headerTo := fmt.Sprintf("To: %s\r\n", tujuanEmail)
	headerSubj := "Subject: Kode Verifikasi OTP - Artha App\r\n"
	headerMime := "MIME-version: 1.0;\r\nContent-Type: text/html; charset=\"UTF-8\";\r\n\r\n"

	// Desain isi Email (Boleh kamu ubah-ubah kalimatnya)
	body := fmt.Sprintf(`
		<div style="font-family: Arial, sans-serif; max-width: 500px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;">
			<h2 style="color: #4D55CC; text-align: center;">Artha App</h2>
			<p>Halo,</p>
			<p>Terima kasih telah mendaftar di Artha App. Berikut adalah kode verifikasi (OTP) Anda:</p>
			<div style="text-align: center; margin: 20px 0;">
				<span style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #333;">%s</span>
			</div>
			<p style="color: #d9534f; font-size: 12px;"><i>*Kode ini hanya berlaku selama 3 menit. Jangan berikan kode ini kepada siapa pun, termasuk pihak Artha.</i></p>
		</div>
	`, kodeOTP)

	// Gabungkan semuanya menjadi satu pesan utuh
	msg := []byte(headerTo + headerSubj + headerMime + body)

	// Kirim email
	err = smtp.SendMail(host+":"+port, auth, senderEmail, []string{tujuanEmail}, msg)
	return err
}
