package main

import (
	"context"
	"github.com/go-redis/redis/v8"
	"time"

	"github.com/redis/go-redis/v9"
	log "github.com/sirupsen/logrus"
)

type ClusterClient struct {
	*redis.ClusterClient
}

// var (
// 	ClusterClient *redis.ClusterClient
// )

// RdbNewClusterClient 连接redis 集群模式
func RdbNewClusterClient(ip []string, pwd string, poolsize int) (*ClusterClient, error) {
	opts := &redis.ClusterOptions{
		Addrs:    ip,
		Password: pwd,
		PoolSize: poolsize,
	}
	client := redis.NewClusterClient(opts)
	if err := client.Ping(context.Background()).Err(); err != nil {
		return nil, err
	}
	return &ClusterClient{client}, nil
}

// RdbClusterSet 进行写入 redis key
func RdbClusterSet(rdb ClusterClient, key string, value any, expiration time.Duration) error {
	err := rdb.Set(context.Background(), key, value, expiration).Err()
	if err != nil {
		log.Error(err)
		return err
	}
	return nil
}

// RdbClusterGet 进行查看redis key
func RdbClusterGet(rdb ClusterClient, key string) (string, error) {
	value, err := rdb.Get(context.Background(), key).Result()
	if err != nil {
		log.Error(err)
		return "", err
	}
	return value, nil
}

// RdbClusterUnlink 进行删除redis key
func RdbClusterUnlink(rdb ClusterClient, key string) error {
	err := rdb.Unlink(context.Background(), key).Err()
	if err != nil {
		log.Error(err)
		return err
	}
	return nil
}
