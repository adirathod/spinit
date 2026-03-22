package utils

import (
	"crypto/rand"
	"math/big"
)

func GenerateShareCode() string {
	const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
	code := make([]byte, 6)
	for i := range code {
		index, _ := rand.Int(rand.Reader, big.NewInt(int64(len(chars))))
		code[i] = chars[index.Int64()]
	}
	return string(code)
}
