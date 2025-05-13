<script setup>
import { RouterView } from 'vue-router'
import Navbar from '@/components/Navbar.vue'
import Footer from '@/components/Footer.vue'
</script>

<template>
  <div class="h-screen flex flex-col">
    <Navbar class="hidden md:flex" />
    <RouterView />
    <Footer class="hidden md:flex" />
  </div>
</template>
