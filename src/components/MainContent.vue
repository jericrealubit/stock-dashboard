<script setup>
import { useSelectedTextStore } from '@/stores/selectedSymbol'
import axios from 'axios'
import { storeToRefs } from 'pinia'
import { ref, watch } from 'vue'

const selectedTextStore = useSelectedTextStore()
const { selectedText } = storeToRefs(selectedTextStore)
const data = ref(null)
const error = ref(null)

const fetchData = async (text) => {
  try {
    //;[0]['Meta Data']['2. Symbol']
    // const response = await axios.get(`http://localhost:8000/stocks/${text}`)
    const response = await axios.get(`http://localhost:8000/stocks`)
    console.log(response.data[0]['Meta Data']['2. Symbol'])
    console.log(response.data[0]['Time Series (5min)'])
    data.value = response.data
    error.value = null
  } catch (err) {
    error.value = err.message
    data.value = null
  }
}

watch(selectedText, (newText) => {
  if (newText) {
    fetchData(newText)
  } else {
    data.value = null
    error.value = null
  }
})
</script>

<template>
  <main class="p-4 flex-1 overflow-y-auto">
    <h2 class="text-lg font-bold mb-4">Stock Informations</h2>
    <p>Clicked Text: {{ selectedTextStore.selectedText }}</p>
  </main>
</template>
