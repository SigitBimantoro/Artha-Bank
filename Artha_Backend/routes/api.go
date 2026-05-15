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
	protected := api.Group("/")
	protected.Use(middlewares.CekTiketJWT(config.DB)) 
	{
		protected.POST("/topup", transactionService.TopUpInternal)
		protected.POST("/logout", authService.LogoutUser)
		protected.POST("/transfer", transactionService.TransferUang)
		protected.POST("/payment/pulsa", transactionService.BeliPulsa)
		protected.POST("/payment/pln", transactionService.BeliTokenListrik)
	}
}