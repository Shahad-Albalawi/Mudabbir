<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Validation Language Lines
    |--------------------------------------------------------------------------
    */

    'accepted' => 'يجب قبول حقل :attribute.',
    'active_url' => 'حقل :attribute ليس عنوان URL صالحاً.',
    'after' => 'يجب أن يكون حقل :attribute تاريخاً بعد :date.',
    'alpha' => 'يجب أن يحتوي حقل :attribute على أحرف فقط.',
    'alpha_dash' => 'يجب أن يحتوي حقل :attribute على أحرف وأرقام وشرطات وشرطات سفلية فقط.',
    'alpha_num' => 'يجب أن يحتوي حقل :attribute على أحرف وأرقام فقط.',
    'array' => 'يجب أن يكون حقل :attribute مصفوفة.',
    'before' => 'يجب أن يكون حقل :attribute تاريخاً قبل :date.',
    'between' => [
        'numeric' => 'يجب أن تكون قيمة :attribute بين :min و :max.',
        'file' => 'يجب أن يكون حجم :attribute بين :min و :max كيلوبايت.',
        'string' => 'يجب أن يكون طول :attribute بين :min و :max حرفاً.',
        'array' => 'يجب أن يحتوي :attribute على عدد عناصر بين :min و :max.',
    ],
    'boolean' => 'يجب أن تكون قيمة حقل :attribute صحيحة أو خاطئة.',
    'confirmed' => 'تأكيد حقل :attribute غير متطابق.',
    'date' => 'حقل :attribute ليس تاريخاً صالحاً.',
    'date_equals' => 'يجب أن يكون حقل :attribute تاريخاً مساوياً لـ :date.',
    'date_format' => 'لا يطابق حقل :attribute الصيغة :format.',
    'different' => 'يجب أن يكون حقل :attribute مختلفاً عن :other.',
    'digits' => 'يجب أن يحتوي حقل :attribute على :digits أرقام.',
    'digits_between' => 'يجب أن يحتوي حقل :attribute على عدد أرقام بين :min و :max.',
    'email' => 'يجب إدخال بريد إلكتروني صالح في حقل :attribute.',
    'exists' => 'القيمة المحددة في :attribute غير صالحة.',
    'file' => 'يجب أن يكون حقل :attribute ملفاً.',
    'filled' => 'حقل :attribute مطلوب.',
    'gt' => [
        'numeric' => 'يجب أن تكون قيمة :attribute أكبر من :value.',
        'file' => 'يجب أن يكون حجم :attribute أكبر من :value كيلوبايت.',
        'string' => 'يجب أن يكون طول :attribute أكبر من :value حرفاً.',
        'array' => 'يجب أن يحتوي :attribute على أكثر من :value عنصر.',
    ],
    'gte' => [
        'numeric' => 'يجب أن تكون قيمة :attribute أكبر من أو تساوي :value.',
        'file' => 'يجب أن يكون حجم :attribute أكبر من أو يساوي :value كيلوبايت.',
        'string' => 'يجب أن يكون طول :attribute أكبر من أو يساوي :value حرفاً.',
        'array' => 'يجب أن يحتوي :attribute على :value عنصراً أو أكثر.',
    ],
    'image' => 'يجب أن يكون حقل :attribute صورة.',
    'in' => 'القيمة المحددة في :attribute غير صالحة.',
    'integer' => 'يجب أن يكون حقل :attribute رقماً صحيحاً.',
    'json' => 'يجب أن يكون حقل :attribute نص JSON صالحاً.',
    'lt' => [
        'numeric' => 'يجب أن تكون قيمة :attribute أقل من :value.',
        'file' => 'يجب أن يكون حجم :attribute أقل من :value كيلوبايت.',
        'string' => 'يجب أن يكون طول :attribute أقل من :value حرفاً.',
        'array' => 'يجب أن يحتوي :attribute على أقل من :value عنصر.',
    ],
    'lte' => [
        'numeric' => 'يجب أن تكون قيمة :attribute أقل من أو تساوي :value.',
        'file' => 'يجب أن يكون حجم :attribute أقل من أو يساوي :value كيلوبايت.',
        'string' => 'يجب أن يكون طول :attribute أقل من أو يساوي :value حرفاً.',
        'array' => 'يجب ألا يحتوي :attribute على أكثر من :value عنصر.',
    ],
    'max' => [
        'numeric' => 'يجب ألا تكون قيمة :attribute أكبر من :max.',
        'file' => 'يجب ألا يكون حجم :attribute أكبر من :max كيلوبايت.',
        'string' => 'يجب ألا يكون طول :attribute أكبر من :max حرفاً.',
        'array' => 'يجب ألا يحتوي :attribute على أكثر من :max عنصر.',
    ],
    'mimes' => 'يجب أن يكون حقل :attribute ملفاً من نوع: :values.',
    'min' => [
        'numeric' => 'يجب أن تكون قيمة :attribute على الأقل :min.',
        'file' => 'يجب أن يكون حجم :attribute على الأقل :min كيلوبايت.',
        'string' => 'يجب أن يكون طول :attribute على الأقل :min حرفاً.',
        'array' => 'يجب أن يحتوي :attribute على الأقل على :min عنصر.',
    ],
    'not_in' => 'القيمة المحددة في :attribute غير صالحة.',
    'numeric' => 'يجب أن يكون حقل :attribute رقماً.',
    'present' => 'يجب تقديم حقل :attribute.',
    'regex' => 'صيغة حقل :attribute غير صالحة.',
    'required' => 'حقل :attribute مطلوب.',
    'required_if' => 'حقل :attribute مطلوب عندما يكون :other هو :value.',
    'required_unless' => 'حقل :attribute مطلوب ما لم يكن :other في :values.',
    'required_with' => 'حقل :attribute مطلوب عند وجود :values.',
    'required_with_all' => 'حقل :attribute مطلوب عند وجود :values.',
    'required_without' => 'حقل :attribute مطلوب عند عدم وجود :values.',
    'required_without_all' => 'حقل :attribute مطلوب عند عدم وجود أي من :values.',
    'same' => 'يجب أن يتطابق حقل :attribute مع :other.',
    'size' => [
        'numeric' => 'يجب أن تكون قيمة :attribute :size.',
        'file' => 'يجب أن يكون حجم :attribute :size كيلوبايت.',
        'string' => 'يجب أن يكون طول :attribute :size حرفاً.',
        'array' => 'يجب أن يحتوي :attribute على :size عنصراً.',
    ],
    'string' => 'يجب أن يكون حقل :attribute نصاً.',
    'timezone' => 'يجب أن يكون حقل :attribute منطقة زمنية صالحة.',
    'unique' => 'قيمة :attribute مستخدمة مسبقاً.',
    'uploaded' => 'فشل رفع حقل :attribute.',
    'url' => 'صيغة حقل :attribute غير صالحة.',

    'attributes' => [
        'name' => 'الاسم',
        'email' => 'البريد الإلكتروني',
        'password' => 'كلمة المرور',
        'content' => 'المحتوى',
        'message' => 'الرسالة',
        'amount' => 'المبلغ',
        'target' => 'المبلغ المستهدف',
        'category' => 'الفئة',
        'date' => 'التاريخ',
    ],

];
