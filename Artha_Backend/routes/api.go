package routes

import (
	"artha/config"
	"artha/controllers"
	"artha/handlers"
	"artha/middlewares"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(r *gin.Engine, authService *controllers.AuthController, transactionService *controllers.TransactionController, historyService *controllers.HistoryController, savingService *controllers.SavingController, favoriteHandler *handlers.FavoriteHandler) {
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
		protected.POST("/payment/qris", middlewares.CekPIN(config.DB), transactionService.BayarQRIS)
		protected.POST("/set-pin", authService.SetUserPin)
		protected.POST("/verify-password", authService.VerifyPassword)
		protected.POST("/change-password", authService.ChangePassword)
		protected.POST("/change-pin", authService.ChangePin)
		protected.GET("/profile", authService.GetProfile)
		protected.GET("/users/by-phone/:phone", authService.GetUserByPhone)
		protected.PUT("/profile", authService.UpdateProfile)
		protected.GET("/history", historyService.GetRiwayatTransaksi)
		protected.GET("/history/summary", historyService.GetTrackingKeuangan)
		protected.GET("/history/summary/pdf", historyService.ExportTrackingKeuanganPDF)
		protected.GET("/savings", savingService.GetSavings)
		protected.POST("/savings", savingService.CreateSaving)
		protected.PUT("/savings/:id", savingService.UpdateSaving)
		protected.DELETE("/savings/:id", savingService.DeleteSaving)
		protected.PUT("/savings/:id/auto-debit", savingService.UpdateAutoDebit)
		protected.POST("/savings/:id/add", savingService.AddSaldo)
		protected.POST("/savings/:id/withdraw", savingService.TarikSaldo)
		protected.GET("/history/transfer", historyService.GetRiwayatTransferKeluar)
		protected.POST("/favorites", favoriteHandler.CreateFavorite)
		protected.GET("/favorites", favoriteHandler.ListFavorites)
		protected.DELETE("/favorites/:id", favoriteHandler.DeleteFavorite)
	}
}
