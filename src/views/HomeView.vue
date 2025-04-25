<script setup>
import Sidebar from '@/components/Sidebar.vue'
import MainContent from '@/components/MainContent.vue'
</script>

<template>
  <div class="h-screen flex flex-col">
    <div class="flex flex-1 overflow-hidden">
      <Sidebar class="h-full" />
      <MainContent />
    </div>
  </div>
</template>
