lcov --add-tracefile coverage/unit_widget.info -a coverage/integration.info -o coverage/lcov.info
sed -i 's/\\/\//g' coverage/lcov.info
genhtml coverage/lcov.info -o coverage/html
