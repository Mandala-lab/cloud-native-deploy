package main

import "github.com/gin-gonic/gin"

func main() {
	s := gin.Default()

	s.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"code": 200,
			"msg":  "OK",
		})
	})

	s.POST("/register", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"code": 200,
			"msg":  "OK",
		})
	})

	s.Run("0.0.0.0:4000")
}
