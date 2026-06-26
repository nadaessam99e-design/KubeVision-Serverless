package io.platform.platform_api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.jdbc.autoconfigure.DataSourceAutoConfiguration;

@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
public class PlatformApiApplication {

	public static void main(String[] args) {
		SpringApplication.run(PlatformApiApplication.class, args);
	}

}
