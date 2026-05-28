package routes

import (
	"artha/config"
	"artha/controllers"
	"artha/middlewares"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(r *gin.Engine, authService *controllers.AuthController, transactionService *controllers.TransactionController) {
	api := r.Group("/api")
		api.POST("/register", authService.RegisterUser)
		api.POST("/verify-otp", authService.VerifyOTP)
		api.POST("/login", authService.LoginUser)
		api.POST("/resend-otp", authService.ResendOTP)
		api.POST("/forgot-password", authService.RequestForgotPassword)
		api.POST("/reset-password", authService.ResetPassword)
	protected := api.Group("/")
	protected.Use(middlewares.CekTiketJWT(config.DB)) 
	{
		protected.POST("/topup", transactionService.TopUpInternal)
		protected.POST("/logout", authService.LogoutUser)
		protected.POST("/transfer", middlewares.CekPIN(config.DB), transactionService.TransferUang)
		protected.POST("/payment/pulsa", middlewares.CekPIN(config.DB), transactionService.BeliPulsa)
		protected.POST("/payment/pln", middlewares.CekPIN(config.DB), transactionService.BeliTokenListrik)
		protected.POST("/set-pin", authService.SetUserPin)
		protected.GET("/history", transactionService.GetRiwayatTransaksi)
		protected.GET("/history/summary", transactionService.GetRingkasanTransaksi)
		
	}
}