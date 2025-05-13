<script setup>
import Sidebar from '@/components/Sidebar.vue'
import MainContent from '@/components/MainContent.vue'
</script>

<template>
  <!-- <div class="flex flex-1 overflow-hidden"> -->
  <div class="flex flex-1 flex-col md:flex-row overflow-hidden">
    <Sidebar />
    <MainContent />
  </div>
</template>
