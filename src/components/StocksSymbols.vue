<script setup>
import axios from 'axios'
import { ref, reactive, onMounted } from 'vue'
import { useSelectedTextStore } from '@/stores/selectedSymbol'

const selectedTextStore = useSelectedTextStore()

const state = reactive({
  symbols: [],
  isLoading: true,
})

const exchage = ref('NASDAQ')
const toggleExchange = async () => {
  exchage.value = exchage.value == 'NYSE' ? 'NASDAQ' : 'NYSE'
  try {
    const response = await axios.get(`/data/${exchage.value}.json`)
    state.symbols = response.data
    console.log(response)
  } catch (error) {
    console.error('Error fetching JSON:', error)
  }
}

onMounted(async () => {
  toggleExchange()
})

const selectedSymbol = ref('')
const handleClick = (event) => {
  selectedSymbol.value = event.target.textContent
  selectedTextStore.setSelectedText(selectedSymbol.value)
}

const handleSubmit = () => {
  selectedTextStore.setSelectedText(selectedSymbol.value)
}
</script>

<template>
  <hr class="border-t border-gray-300 my-4" />

  <h2 class="text-lg font-bold mb-4">Selected Symbol</h2>
  <div class="flex justify-start items-center">
    <input
      v-model="selectedSymbol"
      @keydown.enter="handleSubmit"
      type="text"
      class="uppercase w-20 font-bold border border-green-300 rounded-lg p-2 focus:ring-blue-300 focus:border-blue-300"
      placeholder="Symbol"
    />
    <button
      title="Toggle Exchage"
      @click="handleSubmit"
      class="h-7 ml-3 hover:cursor-pointer bg-blue-500 hover:bg-blue-700 text-white font-bold text-sm px-2 rounded"
    >
      Submit
    </button>
  </div>
  <hr class="border-t border-gray-300 my-4" />

  <div class="flex justify-start">
    <h2 class="text-sm font-bold mb-1">Exchage:</h2>
    <button
      title="Toggle Exchage"
      @click="toggleExchange"
      class="ml-3 hover:cursor-pointer bg-blue-500 hover:bg-blue-700 text-white font-bold text-sm px-2 rounded"
    >
      {{ exchage }}
    </button>
  </div>

  <hr class="border-t border-gray-300 my-4" />
  <h2 class="text-lg font-bold mb-4">Stock Symbols</h2>
  <div class="max-h-[50vh] overflow-y-auto border p-4">
    <div>
      <ul class="divide-y divide-gray-200">
        <li
          @click="handleClick"
          v-for="symbol in state.symbols"
          :key="symbol.Symbol"
          class="py-2 pl-5 odd:bg-gray-300 hover:bg-gray-800 hover:cursor-pointer hover:text-white"
        >
          <div class="flex justify-between" :title="symbol.Description">
            <span class="font-medium">{{ symbol.Symbol }}</span>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>
