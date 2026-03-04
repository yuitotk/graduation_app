// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

eagerLoadControllersFrom("controllers", application)

// ✅ 追加：この1行で確実に controller を登録する（名前は data-controller と一致）
import SearchAutocompleteController from "./search_autocomplete_controller"
application.register("search-autocomplete", SearchAutocompleteController)
