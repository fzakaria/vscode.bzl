package com.example;

import com.google.gson.Gson;

public class Library {
    public static String getGreeting() {
        String greeting = "Hello, World!";
        Gson gson = new Gson();
        return gson.toJson(greeting);
    }
}
