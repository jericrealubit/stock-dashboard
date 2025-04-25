import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useSelectedTextStore = defineStore('selectedText', () => {
  const selectedText = ref('')

  const setSelectedText = (text) => {
    selectedText.value = text
  }

  return { selectedText, setSelectedText }
})
