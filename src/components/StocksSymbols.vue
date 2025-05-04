<script setup>
import axios from 'axios'
import { ref, reactive, onMounted, watch, computed } from 'vue'
import { useSelectedTextStore } from '@/stores/selectedSymbol'

const selectedTextStore = useSelectedTextStore()

const state = reactive({
  stockItems: [],
})

const exchage = ref('NASDAQ')
const toggleExchange = async () => {
  exchage.value = exchage.value == 'NYSE' ? 'NASDAQ' : 'NYSE'
  try {
    const response = await axios.get(`/data/${exchage.value}.json`)
    state.stockItems = response.data
    console.log(response)
    console.log(state.stockItems)
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

///+ favorite

// Reactive state for the list of favorite symbols
const favoriteSymbols = ref([])

// localStorage key for storing favorites
const localStorageKey = 'favoriteStockSymbols'

// --- Computed Property ---
// Creates a sorted list of stock *objects* with favorites appearing first
const sortedStockItems = computed(() => {
  // Create a set of favorited symbols for quick lookup
  const favoriteSet = new Set(favoriteSymbols.value)

  // Sort a copy of the original stockItems array
  return [...state.stockItems].sort((a, b) => {
    const aIsFavorited = favoriteSet.has(a.Symbol)
    const bIsFavorited = favoriteSet.has(b.Symbol)

    // If 'a' is favorited and 'b' is not, 'a' comes first (-1)
    if (aIsFavorited && !bIsFavorited) {
      return -1
    }
    // If 'a' is not favorited and 'b' is, 'b' comes first (1)
    if (!aIsFavorited && bIsFavorited) {
      return 1
    }
    // If both are favorited or both are not, maintain original relative order (0)
    return 0
  })
})

// --- Methods / Logic ---

// Function to check if a symbol is currently in the favorites list
const isSymbolFavorited = (symbol) => {
  return favoriteSymbols.value.includes(symbol)
}

// Function to toggle the favorite status of a symbol
const toggleFavorite = (symbol) => {
  if (isSymbolFavorited(symbol)) {
    // If already favorited, remove it
    favoriteSymbols.value = favoriteSymbols.value.filter((fav) => fav !== symbol)
    console.log(`Removed ${symbol} from favorites.`)
  } else {
    // If not favorited, add it
    favoriteSymbols.value.push(symbol)
    console.log(`Added ${symbol} to favorites.`)
  }
  // No need to manually trigger saveFavorites here, the watch effect handles it
}

// Function to load favorites from localStorage
const loadFavorites = () => {
  const storedFavorites = localStorage.getItem(localStorageKey)
  // Create a set of all valid symbols from the stockItems data
  const validSymbols = new Set(state.stockItems.map((item) => item.Symbol))

  if (storedFavorites) {
    try {
      const parsedFavorites = JSON.parse(storedFavorites)
      if (Array.isArray(parsedFavorites)) {
        // Filter out any symbols in localStorage that are not in our current stockItems list
        favoriteSymbols.value = parsedFavorites.filter((symbol) => validSymbols.has(symbol))
        console.log('Loaded favorites from localStorage:', favoriteSymbols.value)
      } else {
        console.error('Data in localStorage is not an array, clearing:', storedFavorites)
        favoriteSymbols.value = []
        localStorage.removeItem(localStorageKey)
      }
    } catch (e) {
      console.error('Error parsing favorites from localStorage:', e)
      favoriteSymbols.value = []
      localStorage.removeItem(localStorageKey)
    }
  }
}

// Function to save the current favorites list to localStorage
const saveFavorites = () => {
  try {
    localStorage.setItem(localStorageKey, JSON.stringify(favoriteSymbols.value))
    console.log('Saved favorites to localStorage:', favoriteSymbols.value)
  } catch (e) {
    console.error('Error saving favorites to localStorage:', e)
  }
}

// --- Lifecycle Hooks ---

// Load favorites when the component is mounted
onMounted(loadFavorites)

// Watch the favoriteSymbols ref for changes and save to localStorage
watch(favoriteSymbols, saveFavorites, { deep: true })
///- favorite
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
  <div class="max-h-[60vh] overflow-y-auto border p-4">
    <div>
      <ul class="divide-y divide-gray-200">
        <li
          v-for="item in sortedStockItems"
          :key="item.Symbol"
          class="py-2 pl-5 odd:bg-gray-300 hover:bg-gray-400 hover:text-white"
        >
          <div class="flex justify-between">
            <span
              @click="handleClick"
              class="font-medium hover:cursor-pointer"
              :title="item.Description"
              >{{ item.Symbol }}</span
            >
            <span class="whitespace-normal"></span>
            <div :title="isSymbolFavorited(item.Symbol) ? 'unfavorite' : 'favorite'">
              <svg
                @click="toggleFavorite(item.Symbol)"
                xmlns="http://www.w3.org/2000/svg"
                :fill="isSymbolFavorited(item.Symbol) ? 'yellow' : 'none'"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                class="size-6 hover:cursor-pointer"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M11.48 3.499a.562.562 0 0 1 1.04 0l2.125 5.111a.563.563 0 0 0 .475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 0 0-.182.557l1.285 5.385a.562.562 0 0 1-.84.61l-4.725-2.885a.562.562 0 0 0-.586 0L6.982 20.54a.562.562 0 0 1-.84-.61l1.285-5.386a.562.562 0 0 0-.182-.557l-4.204-3.602a.562.562 0 0 1 .321-.988l5.518-.442a.563.563 0 0 0 .475-.345L11.48 3.5Z"
                />
              </svg>
            </div>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>
