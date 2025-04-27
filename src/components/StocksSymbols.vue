<script setup>
import axios from 'axios'
import { ref, reactive, onMounted } from 'vue'
import { useSelectedTextStore } from '@/stores/selectedSymbol'

const selectedTextStore = useSelectedTextStore()

const state = reactive({
  symbols: [],
  isLoading: true,
})

onMounted(async () => {
  try {
    const response = await axios.get('/data/stockssymbols.json')
    state.symbols = response.data
    console.log(response)
  } catch (error) {
    console.error('Error fetching JSON:', error)
  }
})

const handleClick = (event) => {
  selectedTextStore.setSelectedText(event.target.textContent)
}
</script>

<template>
  <h2 class="text-lg font-bold mb-4">Stock Symbols</h2>
  <div class="max-h-[80vh] overflow-y-auto border p-4">
    <div>
      <ul class="divide-y divide-gray-200">
        <li
          @click="handleClick"
          v-for="symbol in state.symbols"
          :key="symbol.Symbol"
          class="py-2 pl-5 odd:bg-gray-300 hover:bg-gray-800 hover:cursor-pointer hover:text-white"
        >
          <div class="flex justify-between">
            <span class="font-medium">{{ symbol.Symbol }}</span>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>
